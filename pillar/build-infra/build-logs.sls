
build-infra:
# public gpg key associated to the one used to sign log commits
# it allows to not rely on gpg key servers
  build_log_public_key: |
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    ...
    -----END PGP PUBLIC KEY BLOCK-----
# ssh key used to access github - needs to have write access to build-logs repository
  github_ssh_key: |
    -----BEGIN RSA PRIVATE KEY-----
    ...
    -----END RSA PRIVATE KEY-----
