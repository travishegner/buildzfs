#!/bin/bash -e

NUM_CPUS="${NUM_CPUS:=4}"
ZFS_GPG_KEY="${ZFS_GPG_KEY:=6AD860EED4598027}"
ZFS_RELEASE="${ZFS_RELEASE:=2.3.1}"

if ls *.zst 1> /dev/null 2>&1; then
  echo "Found existing packages in current directory, please remove before executing."
  exit 1
fi

podman pull docker.io/library/archlinux
podman build -t buildzfs --build-arg=zfs_release=${ZFS_RELEASE} --build-arg=zfs_gpg_key=${ZFS_GPG_KEY} --build-arg=num_cpus=${NUM_CPUS} .

packages=$(podman run --name=buildzfs buildzfs bash -c "ls /zfs-*/*.zst")

for p in $packages
do
  echo $p
  podman cp buildzfs:$p .
done

podman rm buildzfs
podman rmi buildzfs
