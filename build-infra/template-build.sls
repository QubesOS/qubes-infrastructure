builder-dependencies:
  pkg.installed:
    - pkgs:
      - dpkg-dev
      - debootstrap
      - git
      - createrepo_c
      - rpm-build
      - rpm-sign
      - make
      - python3-sh
      - rpmdevtools
      - dialog
      - wget
      - curl
      - qubes-gpg-split
      - python3-pyyaml
      - mock
      - pbuilder
      - reprepro
      - nosync
# dpkg-scanpackages
      - perl-Digest-MD5
      - perl-Digest-SHA
      - devscripts
# for salt gpg module
      - gnupg2
      - python3-gnupg
# for release ISO process
      - mktorrent
# for kernel config
      - flex
      - bison
# extra for builderv2
      - python3-packaging
      - qubes-gpg-split
      - python3-pathspec
      - python3-debian
      - python3-pygithub
      - openssl
      - tree
