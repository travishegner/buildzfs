#!/bin/bash -e

NUM_CPUS="${NUM_CPUS:=4}"
ZFS_GPG_KEY="${ZFS_GPG_KEY:=6AD860EED4598027}"
ZFS_RELEASE="${ZFS_RELEASE:=2.2.5}"
OLD_ZFS_SHA="9790905f7683d41759418e1ef3432828c31116654ff040e91356ff1c21c31ec0"
NEW_ZFS_SHA="2388cf6f29cd75e87d6d05e4858a09d419c4f883a658d51ef57796121cd08897"

if ls *.zst 1> /dev/null 2>&1; then
  echo "Found existing packages in current directory, please remove before executing."
  exit 1
fi

podman pull docker.io/library/archlinux
podman build -t buildzfs --build-arg=zfs_release=${ZFS_RELEASE} --build-arg=zfs_gpg_key=${ZFS_GPG_KEY} --build-arg=num_cpus=${NUM_CPUS} --build-arg=old_sha=${OLD_ZFS_SHA} --build-arg=new_sha=${NEW_ZFS_SHA} .

packages=$(podman run --name=buildzfs buildzfs bash -c "ls /zfs-*/*.zst")

for p in $packages
do
  echo $p
  podman cp buildzfs:$p .
done

podman rm buildzfs
podman rmi buildzfs
