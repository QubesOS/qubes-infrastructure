

build-infra:
# list of build environments:
  build-envs:
    - fedora
    - centos
    - debian
# Default NetVMs and templates:
#  logs-template: fedora-30
#  logs-netvm: sys-firewall
#  build-template: fedora-30
#  build-netvm: sys-whonix
#  keys-template: fedora-30-minimal

# builders in build VMs - this is just example, should be specified per-target
# VM
  builders-list: |
      r4.0=/home/user/builder-r4.0
      r4.1=/home/user/builder-r4.1
  remote-hosts:
    yum.qubes-os.org:
        ssh_user: user
        ssh_host_key: AAAAB3NzaC1yc2EAAAADAQABAAABAQCs7JxW6S2eWv44tS9aXKrk2roSk8FclU7vtdz/hnsThtc3A7VofkGHCaG0xzFjreUvI300/dYQ3P6vehx08S+gpyWC6ILB6S4P4sY+VVl8d9OFenRDFXd+spv9DKEufsZ8x0E7DpopHYWir+NCx5ohw0BDwoeH/VOjQfAEzWy1kRyX2hy9dtO8rM8ykEUrL6bB0SAUF09HuVFhPVnveaLZD13baZcd5uBuqg5+s+atCFVRyr+f9ffBQKW+rE9FEckMV7/RfHF8FHeVZ/wHy+HIUF35I9IiXOr76TbRUttgTXpPU19aAsP91f4ISL8w49cBUiSCd4vYO9wqOV9rmCZ/