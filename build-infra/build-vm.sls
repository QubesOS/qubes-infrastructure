{% set qubes_master_key_fpr = '427F11FD0FAA4B080123F01CDDFA1A3E36879494' %}
{% set commands_keyring = '/home/user/.config/qubes-builder-github/trusted-keys-for-commands.gpg' %}

/usr/local/etc/qubes-rpc/qubesbuilder.CopyTemplateBack:
  file.managed:
    - source: salt://build-infra/qubes-builder/rpc-services/qubesbuilder.CopyTemplateBack
    - mode: 0775
    - makedirs: True

/usr/local/etc/qubes-rpc/qubesbuilder.TriggerBuild:
  file.managed:
    - source: salt://build-infra/qubes-builder-github/rpc-services/qubesbuilder.TriggerBuild
    - mode: 0755
    - makedirs: True

/usr/local/etc/qubes-rpc/qubesbuilder.ProcessGithubCommand:
  file.managed:
    - source: salt://build-infra/qubes-builder-github/rpc-services/qubesbuilder.ProcessGithubCommand
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

commands-keyring:
  cmd.run:
    - name: rm -f {{ commands_keyring }}; gpg2 --no-default-keyring --keyring {{ commands_keyring }} --import /home/user/trusted-keys-for-commands.asc
    - runas: user
    - onchange:
      - file: /home/user/trusted-keys-for-commands.asc
