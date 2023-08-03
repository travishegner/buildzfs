FROM archlinux

ARG zfs_gpg_key
ARG num_cpus
ARG zfs_release

RUN pacman --noconfirm -Syu && \
  pacman --noconfirm -S linux linux-headers base-devel git glibc && \
  useradd arch && \
  git clone https://aur.archlinux.org/zfs-utils.git && \
  git clone https://aur.archlinux.org/zfs-linux.git && \
  mkdir -p /home/arch/.gnupg && \
  chown -R arch /home/arch /zfs-utils /zfs-linux && \
  sed -i "s/^#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$num_cpus\"/g" /etc/makepkg.conf && \
  sed -i "s/^_kernelver=\".*\"/_kernelver=\"$(pacman -Q linux | cut -d ' ' -f 2)\"/g" /zfs-linux/PKGBUILD && \
  sed -i "s/^_kernelver_full=\".*\"/_kernelver_full=\"$(pacman -Q linux | cut -d ' ' -f 2)\"/g" /zfs-linux/PKGBUILD && \
  sed -i "s/^_zfsver=\".*\"/_zfsver=\"$zfs_release\"/g" /zfs-linux/PKGBUILD && \
  sed -i "s/^pkgver=\".*\"/pkgver=\"$zfs_release\"/g" /zfs-utils/PKGBUILD

USER arch

RUN gpg --recv-keys $zfs_gpg_key && \
  cd /zfs-utils && \
  makepkg

USER root

RUN pacman --noconfirm -U /zfs-utils/*.zst

USER arch

RUN cd /zfs-linux && \
  makepkg
