

build-infra:
# list of build environments:
  build-envs:
    - fedora
    - debian

# builders in build VMs - this is just example, should be specified per-target
# VM
  builders-list: |
      r3.1=/home/user/builder-r3.1
      r3.2=/home/user/builder-r3.2
      r4.0=/home/user/builder-r4.0
