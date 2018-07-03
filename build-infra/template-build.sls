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
      - python2-pyyaml
      - python3-PyYAML
# dpkg-scanpackages
      - perl-Digest-MD5
      - perl-Digest-SHA
# for salt gpg module
      - gnupg
      - python2-gnupg
# for release ISO process
      - mktorrent
