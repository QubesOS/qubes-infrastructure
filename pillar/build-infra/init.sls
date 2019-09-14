

build-infra:
# Default NetVMs and templates:
#  logs-template: fedora-30
#  logs-netvm: sys-firewall
#  build-template: fedora-30
#  build-netvm: sys-whonix
#  keys-template: fedora-30-minimal

# example list of build environments:
  build-envs:
    fedora1:
      builders-list:
        /home/user/builder-r4.0:
          release: 4.0
          config: qubes-os-r4.0-dom0.conf
        /home/user/builder-r4.1:
          release: 4.1
          config: qubes-os-r4.1-dom0.conf
      volume-size: 20GiB
    fedora2:
      builders-list:
        /home/user/builder-r4.0:
          release: 4.0
          config: qubes-os-r4.0-fedora.conf
        /home/user/builder-r4.1:
          release: 4.1
          config: qubes-os-r4.1-fedora.conf
      volume-size: 20GiB
    centos1:
      builders-list:
        /home/user/builder-r4.0:
          release: 4.0
          config: qubes-os-r4.0-centos.conf
        /home/user/builder-r4.1:
          release: 4.1
          config: qubes-os-r4.1-centos.conf
      volume-size: 20GiB
    debian1:
      builders-list:
        /home/user/builder-r4.0:
          release: 4.0
          config: qubes-os-r4.0-debian.conf
        /home/user/builder-r4.1:
          release: 4.1
          config: qubes-os-r4.1-debian.conf
      volume-size: 20GiB

# Above definitions of environments can be put in
# separate pillar files. Just ensure to keep at least
# the env names for init.top
#   build-envs:
#     fedora1
#     fedora2
#     centos1
#     debian1

# list of remote hosts used to push packages
  remote-hosts:
    yum.qubes-os.org:
        ssh_user: user
        ssh_host_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQCs7JxW6S2eWv44tS9aXKrk2roSk8FclU7vtdz/hnsThtc3A7VofkGHCaG0xzFjreUvI300/dYQ3P6vehx08S+gpyWC6ILB6S4P4sY+VVl8d9OFenRDFXd+spv9DKEufsZ8x0E7DpopHYWir+NCx5ohw0BDwoeH/VOjQfAEzWy1kRyX2hy9dtO8rM8ykEUrL6bB0SAUF09HuVFhPVnveaLZD13baZcd5uBuqg5+s+atCFVRyr+f9ffBQKW+rE9FEckMV7/RfHF8FHeVZ/wHy+HIUF35I9IiXOr76TbRUttgTXpPU19aAsP91f4ISL8w49cBUiSCd4vYO9wqOV9rmCZ/