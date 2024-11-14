FROM artixlinux

ARG zfs_gpg_key
ARG num_cpus
ARG zfs_release
ARG old_sha
ARG new_sha

RUN pacman --noconfirm -Syu && \
  pacman --noconfirm -S linux-lts linux-lts-headers base-devel git glibc && \
  useradd artix && \
  git clone https://aur.archlinux.org/zfs-utils.git && \
  git clone https://aur.archlinux.org/zfs-linux-lts.git && \
  mkdir -p /home/artix/.gnupg && \
  chown -R artix /home/artix /zfs-utils /zfs-linux-lts && \
  sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$num_cpus\"/g" /etc/makepkg.conf

USER artix

RUN cd /zfs-utils && \
  gpg --recv-keys $zfs_gpg_key && \
  sed -i "s/^pkgver=\".*\"/pkgver=\"$zfs_release\"/g" /zfs-utils/PKGBUILD && \
  makepkg

USER root

RUN pacman --noconfirm -U /zfs-utils/*.zst

USER artix

RUN cd /zfs-linux-lts && \
  sed -i "s/^_kernelver=\".*\"/_kernelver=\"$(pacman -Q linux-lts | cut -d ' ' -f 2)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_kernelver_full=\".*\"/_kernelver_full=\"$(ls /usr/lib/modules/)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_extramodules=\".*\"/_extramodules=\"$(ls /usr/lib/modules/)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_zfsver=\".*\"/_zfsver=\"$zfs_release\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/$old_sha/$new_sha/g" /zfs-linux-lts/PKGBUILD && \
  makepkg
