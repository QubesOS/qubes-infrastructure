/home/user/.ssh/config-ssh-proxy:
  file.append:
    - name: /home/user/.ssh/config
    - makedirs: True
    - text: |
        Host *
            ControlMaster auto
            ControlPath ~/.ssh/ctl-%r@%h:%p
            ControlPersist 60s
            ProxyCommand /usr/bin/qrexec-client-vm {{ salt['pillar.get']('build-infra:netvm', 'sys-net') }} local.ConnectSSH+%h
            UseRoaming no

/home/user/.ssh:
  file.directory:
    - user: user
    - group: user
    - recurse:
      - user
      - group
