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
   in appropriate `build-` VMs. See below for detailed list.


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

The build process may be triggered manually (be calling appropriate `make`
command in some of build VM), or in response to github notification. The later
is achieved using
[builder-github](https://github.com/QubesOS/qubes-builder-github), which
provide webhooks and qrexec services to handle this process. It boils down to:

1. HTTP server in `sys-net` (nginx) receive HTTP POST request from github with
   information about an event in repository. It is handed to appropriate
   handler script from `github-webhooks` directory of `builder-github`.
2. Webhook handler extract essential data (for example repository name) and
   send it to all build VMs using `qubesbuilder.TriggerBuild` qrexec service.
3. Qrexec service in a build VM check if the named component exists in any of
   `qubes-builder` instance and call `scripts/auto-build` build script. This
   script check if anything new needs to be built - and if so, build it and
   upload to current-testing repository. This, among other things, report
   successful (or failed) build as an issue in appropriate repository.

Very similar approach is used to move packages from `current-testing` to
`current` repository:

1. HTTP server in `sys-net` (nginx) receive HTTP POST request from github with
   information about an comment on issue. It is handed to appropriate
   handler script from `github-webhooks` directory of `builder-github`.
2. Webhook handler extract commend body, check if it have any PGP-signed data
   (but do not verify it yet) and
   send it to all build VMs using `qubesbuilder.ProcessGithubCommand` qrexec service.
3. Qrexec service in a build VM check signature on the commend and if it's made
   by a trusted key, process the command. See documentation in
   [builder-github](https://github.com/QubesOS/qubes-builder-github) for
   details.



               .-,(  ),-.                     .------------.
            .-(          )-.    HTTP POST     | sys-net    |
           (     github     )****************>|            |
            '-(          ).-'                 |            |
                '-.( ).-'                     '------------'
                    ^                                |
                    *                 qubesbuilder.TriggerBuild
           github issue/comment       qubesbuilder.ProcessGithubCommand
                    *                                |
                    *          .----------.          |
                    ***********| build VM |<---------|
                    *          '----------'          |
                    *                                |
                    *          .----------.          |
                    ***********| build VM |<---------'
                    *          '----------'
                    *
                 packages
                    *
                    v
               .-,(  ),-.
            .-(          )-.
           (   repository   )
            '-(          ).-'
                '-.( ).-'
    

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


Post installation steps
------------------------

Configuration tasks not included in this formula:

1. In each keys VM:

   - [ ] generate/import appropriate signing key

2. In each build VM:

   - [ ] generate/import ssh key used to upload packages
   - [ ] set username in `.ssh/config` for host where packages are uploaded (`yum.qubes-os.org`, `deb.qubes-os.org` etc)
   - [ ] populate `.ssh/known_hosts` for example by logging into updates server and verifying fingerprint
   - [ ] clone (and verify signed tag!) `qubes-builder` into directories listed in `~/.config/qubes-builder-github/builders.list`
   - [ ] setup `builder.conf` in each instance, based on appropriate config in `release-configs/`. In most cases it's enough to create a symlink. When creating new config, make sure to:

     - drop `NO_SIGN ?= 1` line
     - adjust `DISTS_VM` and `DIST_DOM0` if needed (must be set using `?=` operator)
     - adjust COMPONENTS, add builder-github there (must be set using `?=` operator, cannot use `+=`)
     - set `SIGN_KEY` to appropriate key id (the one in matching keys VM)
     - set `LINUX_REPO_BASEDIR` to a appropriate directory (pointing exact release version, like `$(SRC_DIR)/linux-yum/r4.0`)
     - include `$(HOME)/builder-github.conf`

3. In `build-logs` VM:

  - [ ] generate/import ssh key, add it to QubesOS/build-logs repository as deploy key with write access
  - [ ] import logs signing key

4. Make sure build VMs are large enough.
