#!/bin/bash -e

NUM_CPUS="${NUM_CPUS:=4}"
ZFS_GPG_KEY="${ZFS_GPG_KEY:=6AD860EED4598027}"
ZFS_RELEASE="${ZFS_RELEASE:=2.2.6}"
OLD_ZFS_SHA="9790905f7683d41759418e1ef3432828c31116654ff040e91356ff1c21c31ec0"
NEW_ZFS_SHA="c92e02103ac5dd77bf01d7209eabdca55c7b3356aa747bb2357ec4222652a2a7"

if ls *.zst 1> /dev/null 2>&1; then
  echo "Found existing packages in current directory, please remove before executing."
  exit 1
fi

podman pull docker.io/artixlinux/artixlinux
podman build -t buildzfs --build-arg=zfs_release=${ZFS_RELEASE} --build-arg=zfs_gpg_key=${ZFS_GPG_KEY} --build-arg=num_cpus=${NUM_CPUS} --build-arg=old_sha=${OLD_ZFS_SHA} --build-arg=new_sha=${NEW_ZFS_SHA} .

packages=$(podman run --name=buildzfs buildzfs bash -c "ls /zfs-*/*.zst")

for p in $packages
do
  echo $p
  podman cp buildzfs:$p .
done

podman rm buildzfs
podman rmi buildzfs
