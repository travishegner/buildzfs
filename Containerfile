FROM archlinux

ARG zfs_gpg_key
ARG num_cpus
ARG zfs_release
ARG old_sha
ARG new_sha

RUN pacman --noconfirm -Syu && \
  pacman --noconfirm -S linux-lts linux-lts-headers base-devel git glibc && \
  useradd arch && \
  git clone https://aur.archlinux.org/zfs-utils.git && \
  git clone https://aur.archlinux.org/zfs-linux-lts.git && \
  mkdir -p /home/arch/.gnupg && \
  chown -R arch /home/arch /zfs-utils /zfs-linux-lts && \
  sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$num_cpus\"/g" /etc/makepkg.conf

USER arch

RUN cd /zfs-utils && \
  gpg --recv-keys $zfs_gpg_key && \
  sed -i "s/^pkgver=\".*\"/pkgver=\"$zfs_release\"/g" /zfs-utils/PKGBUILD && \
  makepkg

USER root

RUN pacman --noconfirm -U /zfs-utils/*.zst

USER arch

RUN cd /zfs-linux-lts && \
  sed -i "s/^_kernelver=\".*\"/_kernelver=\"$(pacman -Q linux-lts | cut -d ' ' -f 2)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_kernelver_full=\".*\"/_kernelver_full=\"$(ls /usr/lib/modules/)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_extramodules=\".*\"/_extramodules=\"$(ls /usr/lib/modules/)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_zfsver=\".*\"/_zfsver=\"$zfs_release\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/9790905f7683d41759418e1ef3432828c31116654ff040e91356ff1c21c31ec0/2388cf6f29cd75e87d6d05e4858a09d419c4f883a658d51ef57796121cd08897/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/$old_sha/$new_sha/g" /zfs-linux-lts/PKGBUILD && \
  makepkg
