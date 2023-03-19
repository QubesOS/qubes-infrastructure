build-infra:
  github_api_key: place API key here for qubesos-bot account
  openqa_server: openqa.qubes-os.org
  openqa_key: 123456789
  openqa_secret: 123456789
  mirror_ssh_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
# public GPG keys for allowing Qubes members to build packages/templates
  commands_public_keys: |
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    ...
    -----END PGP PUBLIC KEY BLOCK-----
    -----BEGIN PGP PUBLIC KEY BLOCK-----
    ...
    -----END PGP PUBLIC KEY BLOCK-----
