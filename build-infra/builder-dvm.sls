/usr/local/etc/qubes-rpc/qubesbuilder.FileCopyIn:
  file.managed:
    - makedirs: True
    - mode: 0755
    - source: salt://build-infra/qubes-builderv2/rpc/qubesbuilder.FileCopyIn

/usr/local/etc/qubes-rpc/qubesbuilder.FileCopyOut:
  file.managed:
    - makedirs: True
    - mode: 0755
    - source: salt://build-infra/qubes-builderv2/rpc/qubesbuilder.FileCopyOut

/rw/bind-dirs/builder:
  file.directory: []

/rw/config/qubes-bind-dirs.d/builder.conf:
  file.managed:
    - makedirs: True
    - contents: |
        binds+=('/builder')

/rw/config/rc.local:
  file.managed:
    - mode: 0755
    - contents: |
        #!/bin/sh
        mount /builder -o dev,suid,remount
