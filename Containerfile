FROM archlinux

ARG zfs_gpg_key
ARG num_cpus
ARG zfs_release

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
  sed -i "s/^pkgver=\"\?.*\"\?/pkgver=\"$zfs_release\"/g" /zfs-utils/PKGBUILD && \
  sed -i "s/80da628a9543ec3355bf410617450e167706948ceb287541455a1b8d87b8758a/844122118f0ea81205a01753bbcb1315330f8967c1f866dcd10155273131f071/g" /zfs-utils/PKGBUILD && \
  sed -i "s/8a89c62cbbeaf410db4011821cdd9959abef1782be7427b81ac47565407384fa3a381bef041dae73e97c2b2cefca62933180851901b3b1b86974ed33ad178a61/4861ddfc91b941448d13d43bb2a023273917064b29880f87d91dbe6424b3f1fc7b0409e13a514d5b3f18f70a383c5d1c462ec5d7b8a7c82b2b076ecd363cecdd/g" /zfs-utils/PKGBUILD && \
  makepkg

USER root

RUN pacman --noconfirm -U /zfs-utils/*.zst

USER arch

RUN cd /zfs-linux-lts && \
  sed -i "s/^_kernelver=\".*\"/_kernelver=\"$(pacman -Q linux-lts | cut -d ' ' -f 2)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_kernelver_full=\".*\"/_kernelver_full=\"$(ls /usr/lib/modules/)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_extramodules=\".*\"/_extramodules=\"$(ls /usr/lib/modules/)\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/^_zfsver=\".*\"/_zfsver=\"$zfs_release\"/g" /zfs-linux-lts/PKGBUILD && \
  sed -i "s/80da628a9543ec3355bf410617450e167706948ceb287541455a1b8d87b8758a/844122118f0ea81205a01753bbcb1315330f8967c1f866dcd10155273131f071/g" /zfs-linux-lts/PKGBUILD && \
  makepkg
