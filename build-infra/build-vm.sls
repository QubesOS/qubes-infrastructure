{% set qubes_master_key_fpr = '427F11FD0FAA4B080123F01CDDFA1A3E36879494' %}

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

# populate keys to ease qubes-builder verification
{{qubes_master_key_fpr}}:
  gpg.present:
    - user: user
# this does not work when fpr is used instead of keyid; and gpg.present does
# not allow to specify fpr
#    - trust: ultimately

# gpg module (until salt 2016.3.4) does not chown keyring (bug 36824)
/home/user/.gnupg:
  file.directory:
    - user: user
    - group: user
    - recurse:
      - user
      - group
    - onchange:
      - gpg: {{qubes_master_key_fpr}}

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
