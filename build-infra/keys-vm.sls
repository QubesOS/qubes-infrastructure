/usr/local/etc/qubes-rpc/qubesbuilder.LogReceived:
  file.managed:
    - contents: |
        #!/bin/sh
        touch /var/run/qubes-gpg-split/stat.$1
    - mode: 0755
    - makedirs: True
