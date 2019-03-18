{% set qubes_master_key_fpr = '427F11FD0FAA4B080123F01CDDFA1A3E36879494' %}
{% set commands_keyring = '/home/user/.config/qubes-builder-github/trusted-keys-for-commands.gpg' %}
{% set last_builder_dir = (salt['pillar.get']('build-infra:builders-list').splitlines()|last).split('=')|last %}

/usr/local/etc/qubes-rpc/qubesbuilder.CopyTemplateBack:
  file.symlink:
    - target: {{ last_builder_dir }}/rpc-services/qubesbuilder.CopyTemplateBack
    - force: True
    - mode: 0775
    - makedirs: True

/usr/local/etc/qubes-rpc/qubesbuilder.TriggerBuild:
  file.symlink:
    - target: {{ last_builder_dir }}/qubes-src/builder-github/rpc-services/qubesbuilder.TriggerBuild
    - force: True
    - mode: 0755
    - makedirs: True

/usr/local/etc/qubes-rpc/qubesbuilder.ProcessGithubCommand:
  file.symlink:
    - target: {{ last_builder_dir }}/qubes-src/builder-github/rpc-services/qubesbuilder.ProcessGithubCommand
    - force: True
    - mode: 0755
    - makedirs: True

/usr/local/lib/qubes-builder-github:
  file.symlink:
    - target: {{ last_builder_dir }}/qubes-src/builder-github/lib
    - force: True
    - mode: 0755
    - makedirs: True

/home/user/.config/qubes-builder-github/builders.list:
  file.managed:
    - mode: 0644
    - user: user
    - contents_pillar: build-infra:builders-list
    - makedirs: True

/rw/config/gpg-split-domain:
  file.managed:
    - contents:
      - {{ grains['id']|replace('build-', 'keys-') }}
    - mode: 0644
    - user: user

/home/user/.rpmmacros:
  file.managed:
    - source: salt://build-infra/rpmmacros
    - mode: 0644
    - user: user
    - group: user

/home/user/qubes-master-key.asc:
  file.managed:
    - source: salt://build-infra/qubes-master-key.asc
    - user: user

# populate keys to ease qubes-builder verification
gpg --import /home/user/qubes-master-key.asc:
  cmd.run:
    - runas: user
    - onchange:
      - file: /home/user/qubes-master-key.asc

echo {{qubes_master_key_fpr}}:6 | gpg --import-ownertrust:
  cmd.run:
    - runas: user
    - requires:
      - gpg: {{qubes_master_key_fpr}}

/home/user/builder-github.conf:
  file.managed:
    - source: salt://build-infra/builder-github.conf
    - template: jinja
    - user: user
    - mode: 0600

/home/user/github-notify-state:
  file.directory:
    - makedirs: True
    - user: user
    - mode: 0755

/home/user/trusted-keys-for-commands.asc:
  file.managed:
    - contents_pillar: build-infra:commands_public_keys
    - user: user
    - mode: 0644

/usr/local/bin/builder-cleanup:
  file.managed:
    - source: salt://build-infra/builder-cleanup
    - mode: 0755

/home/user/.config/systemd/user/builder-cleanup.service:
  file.managed:
    - source: salt://build-infra/builder-cleanup.service
    - mode: 0644
    - user: user
    - makedirs: true

/home/user/.config/systemd/user/builder-cleanup.timer:
  file.managed:
    - source: salt://build-infra/builder-cleanup.timer
    - mode: 0644
    - user: user
    - makedirs: true

/home/user/.config/systemd/user/timers.target.wants/builder-cleanup.timer:
  file.symlink:
    - target: ../builder-cleanup.timer
    - force: True
    - mode: 0755
    - makedirs: True

commands-keyring:
  cmd.run:
    - name: rm -f {{ commands_keyring }}; LC_ALL=C.utf8 gpg2 --no-default-keyring --keyring {{ commands_keyring }} --import /home/user/trusted-keys-for-commands.asc
    - runas: user
    - onchange:
      - file: /home/user/trusted-keys-for-commands.asc
