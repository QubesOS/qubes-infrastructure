Qubes OS build infrastructure configuration
===========================================

This repository contains part of Qubes OS infrastructure configuration.

`build-infra` formula
----------------------

This formula provides setup for Qubes OS build machine. It can consists of
multiple build environments, each of them have at least two VMs:

 - build-`ENV_NAME`
 - keys-`ENV_NAME`

In addition to those, `build-logs` VM is created. Configuration allows:

 - build VM to upload build logs to `build-logs` VM
 - `build-logs` VM to unlock signing keys usage for appropriate keys VM
 - build VM access the keys VM

Each build VM have access to the network through Whonix Gateway, so all
3rd-party sources are downloaded through Tor.

Build environments list can be specified with `build-infra:build-envs` pillar.
Example pillar is provided in `/srv/pillar/base/qubesos-infra/build-infra.sls`.

### Usage:

1. Enable this formula with:

        qubesctl top.enable build-infra
        qubesctl top.enable build-infra pillar=True

2. Apply the configuration:

        qubesctl --all state.highstate

3. Provision gpg signing keys into appropriate `keys-` VMs, setup qubes-builder
   in appropriate `build-` VMs.


`build-infra.ssh-proxy` formula
--------------------------------

Configure ssh in build VMs to bypass Whonix Gateway. The main reason here is
performance. This shouldn't affect main goal of using Tor - making targeted
attacks harder, for attacker controlling 3rd-party signing key. Ssh is used only to:
 - download our code from github (where it's authenticated using gpg)
 - upload binary packages to appropriate repositories

Technically it's done by configuring ssh (`ProxyCommand` in
`~/.ssh/config`) to use `local.ConnectSSH` service to `sys-net` (and pass
destination hostname in service argument), instead of establishing TCP
connection directly. `local.ConnectSSH` service is implemented as simple netcat.

### Usage:

1. Enable this formula:

        qubesctl top.enable build-infra.ssh-proxy

2. Apply the configuration:

        qubesctl --all state.highstate



Detailed description of the infrastructure
==========================================

Build infrastructure consists of several build environments. Each of them use 3 VMs:

1. Build VM (`build-*`), responsible for:
  - building the package with logging to build-logs VM in real time
  - sending build artifacts to Keys VM for signing (using split gpg)
  - uploading signed packages to repository
  - sending notifications to github (issue comments etc)

2. Keys VM (`keys-*`), responsible for:
  - keeping signing keys
  - signing packages, but only if build-logs VM acknowledged build log reception

3. Build logs VM (`build-logs`), common for all build environments, responsible for:
  - receiving build logs
  - sending them (in form of signed commits) to build-logs repository
  - signaling appropriate Keys VM of successful logs reception and sending

The above workflow and used qrexec services can be illustrated with the diagram below:


          .-----------.                     .----------.
          | build VM  |                     | keys VM  |
          |           |     4. qubes.Gpg    |          |
          |           |-------------------->|          |
          |           |                     |          |
          |           |                     |          |
          |           |                     '----------'
          '-----------'                              ^
                |                                    |
                |1. qubesbuilder.BuildLog            |
                |                                    |
                v                                    |
        .---------------. 3. qubesbuilder.LogReceived|
        | build-logs VM |----------------------------'
        |               |                         .-,(  ),-.    
        |               | 2. push signed logs  .-(          )-. 
        |               |********************>(     github     )
        |               |                      '-(          ).-'
        |               |                          '-.( ).-'    
        '---------------'


In addition to the above, build VM use Tor to download 3rd-party software
(including build dependencies etc). This is to make _targeted_ attack as hard as
possible even for someone having write access to 3rd-party source/binary
repository (including access to a signing key).

The above architecture is designed to make the build process as transparent as
possible, while limiting damages of a compromised single build environment.
Especially:

- Build VM doesn't have direct access to a signing key, so it's impossible to leak
  it from there.
- Packages signed with different keys are built in separate build environments.
  This means separate build environments for:
  - Fedora packages,
  - Debian packages,
  - Community-supported templates,
  - Contributed packages (TBD),
- Build VM send build logs in real time - so even if the build environment
  would be compromised in the build process, it won't be able to erase the
  evidences from the build log. Note that after build VM is compromised, one
  can no longer trust further build logs, as those can be easily falsified. But
  those produced in the past (including the exact compromise incident) should
  remain immutable.
- Build VM can request package signing only when sent a build log first. It's
  important to stress out here that Keys VM have no way to verify if the build
  log really corresponds to the binary received for signing. But since every
  build is logged in real time and it's a requirement for having package
  signed, logs will be available (publicly) and can be audited.
