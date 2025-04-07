gpg-pkgs:
  pkg.installed:
    - pkgs:
      - qubes-gpg-split
      - gnupg2
# for salt gpg module
      - python3-gnupg
# for windows signing
      - osslsigncode
      - openssl
