/usr/local/etc/qubes-rpc/local.ConnectSSH:
  file.managed:
    - contents:
      - exec /bin/nc "$1" 22
    - mode: 0755
    - makedirs: True
