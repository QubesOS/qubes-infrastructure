

build-infra:
# list of build environments:
  build-envs:
    - fedora
    - debian
# Default NetVMs and templates:
#  logs-template: fedora-24
#  logs-netvm: sys-firewall
#  build-template: fedora-24
#  build-netvm: sys-whonix
#  keys-template: fedora-24-minimal

# builders in build VMs - this is just example, should be specified per-target
# VM
  builders-list: |
      r3.1=/home/user/builder-r3.1
      r3.2=/home/user/builder-r3.2
      r4.0=/home/user/builder-r4.0
