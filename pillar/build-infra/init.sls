

build-infra:
# Default NetVMs and templates:
#  netvm: sys-net
#  logs-template: fedora-40
#  logs-netvm: sys-firewall
#  build-template: fedora-40
#  build-netvm: sys-whonix
#  keys-template: fedora-40-minimal

# example list of build environments:
  build-envs:
    fedora1:
      builders-list:
        /home/user/builder-r4.2:
          release: 4.2
          config:
            - file: R4.2/qubes-os-r4.2-host.conf
            - repository:
                - baseurl: https://github.com/QubesOS-contrib/qubes-
                - component: contrib-configs
                - maintainers:
                    - 9FA64B92F95E706BF28E2CA6484010B5CDC576E2
        /home/user/builder-r4.1:
          release: 4.1
          config:
            - file: R4.1/qubes-os-r4.1-dom0.conf
            - repository:
                - baseurl: https://github.com/QubesOS/qubes-
                - component: release-configs
      volume-size: 20GiB
      logs: logs
    fedora2:
      builderv2: True
      builders-list:
        /home/user/builder-r4.2:
          release: 4.2
          config:
            - file: R4.2/qubes-os-r4.2-dom0.yml
            - repository:
                - baseurl: https://github.com/QubesOS/qubes-
                - component: release-configs
      volume-size: 20GiB
      logs: logs
      # setup for building windows tools too
      windows: true
    kernel:
      builders-list:
        /home/user/builder-r4.1-kernel:
          keys:
            - 9FA64B92F95E706BF28E2CA6484010B5CDC576E2
          release: 4.1
          config:
            - file: qubes-kernel.conf
            - repository:
                - baseurl: https://github.com/fepitre/qubes-
                - component: linux-kernel-updater
      volume-size: 20GiB
      logs: logs-kernel

# Above definitions of environments can be put in
# separate pillar files. Just ensure to keep at least
# the env names for init.top
#   build-envs:
#     fedora1: {}
#     fedora2: {}

# list of remote hosts used to push packages
  remote-hosts:
    yum.qubes-os.org:
        ssh_user: user
        ssh_host_enc: ssh-rsa
        ssh_host_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQCs7JxW6S2eWv44tS9aXKrk2roSk8FclU7vtdz/hnsThtc3A7VofkGHCaG0xzFjreUvI300/dYQ3P6vehx08S+gpyWC6ILB6S4P4sY+VVl8d9OFenRDFXd+spv9DKEufsZ8x0E7DpopHYWir+NCx5ohw0BDwoeH/VOjQfAEzWy1kRyX2hy9dtO8rM8ykEUrL6bB0SAUF09HuVFhPVnveaLZD13baZcd5uBuqg5+s+atCFVRyr+f9ffBQKW+rE9FEckMV7/RfHF8FHeVZ/wHy+HIUF35I9IiXOr76TbRUttgTXpPU19aAsP91f4ISL8w49cBUiSCd4vYO9wqOV9rmCZ/
