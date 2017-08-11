builder-dependencies:
  pkg.installed:
    - pkgs:
      - dpkg-dev
      - debootstrap
      - git
      - createrepo
      - rpm-build
      - rpm-sign
      - make
      - python2-sh
      - rpmdevtools
      - dialog
      - wget
      - curl
      - qubes-gpg-split
      - PyYAML
# for salt gpg module
      - gnupg
      - python2-gnupg
