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
      - curl
      {% if grains['os'] == 'Fedora' and grains['osmajorrelease'] >= 41 -%}
      - wget2-wget
      {% else -%}
      - wget
      {% endif -%}
      - qubes-gpg-split
      - python3-pyyaml
      - mock
      - pbuilder
      - reprepro
      - nosync
      - dosfstools
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
      - pykickstart
      - python3-packaging
      - python3-pathspec
      - python3-debian
      - python3-pygithub
      - openssl
      - tree
      - sequoia-sq
      - sequoia-sqv
      - sequoia-chameleon-gnupg
# for mkmetalink
      - python3-aiohttp
      - python3-lxml
      - python3-jinja2
# for arch packages (builderv2)
      - python3-jinja2-cli
      - pacman
      - m4
      - asciidoc
# windows builds
      - genisoimage
      - osslsigncode


# enable ripemd160 hash, necessary for metalink
/etc/pki/tls/openssl.cnf:
  file.uncomment:
    - regex: "activate = 1|.*default_sect|.*legacy_sect"
    - char: "##"
