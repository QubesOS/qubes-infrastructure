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
      - python-sh
      - rpmdevtools
      - dialog
      - wget
      - curl
      - qubes-gpg-split
# for salt gpg module
      - gnupg
      - python2-gnupg
