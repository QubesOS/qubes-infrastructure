/home/user/.ssh/config:
  file.append:
    - makedirs: True
    - text: |
        Host *
            ControlMaster auto
            ControlPath ~/.ssh/ctl-%r@%h:%p
            ControlPersist 60s
            ProxyCommand /usr/bin/qrexec-client-vm sys-net local.ConnectSSH+%h
            UseRoaming no

/home/user/.ssh:
  file.directory:
    - user: user
    - group: user
    - recurse:
      - user
      - group
