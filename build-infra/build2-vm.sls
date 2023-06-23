{% set qubes_master_key_fpr = '427F11FD0FAA4B080123F01CDDFA1A3E36879494' %}
{% set commands_keyring = '/home/user/.config/qubes-builder-github/trusted-keys-for-commands.gpg' %}
{% set builder_maintainers_keyring = '/home/user/.config/qubes-builder-github/builder-maintainers-keyring' %}
{% set import_master_key = 'gpg --import /home/user/qubes-master-key.asc'|yaml_encode %}
{% set env = grains['id']|replace('build-','') %}
{% set builders_list = salt['pillar.get']('build-infra:build-envs:' + env + ':builders-list', {}).keys() %}
{% set builder_dir = '/home/user/qubes-builderv2' %}
{% set builder_github_dir = '/home/user/qubes-builderv2-github' %}

/usr/local/etc/qubes-rpc/qubesbuilder.TriggerBuild:
  file.symlink:
    - target: {{ builder_github_dir }}/rpc-services/qubesbuilder.TriggerBuild
    - force: True
    - mode: 0755
    - makedirs: True

/usr/local/etc/qubes-rpc/qubesbuilder.ProcessGithubCommand:
  file.symlink:
    - target: {{ builder_github_dir }}/rpc-services/qubesbuilder.ProcessGithubCommand
    - force: True
    - mode: 0755
    - makedirs: True

/usr/local/lib/qubes-builder-github:
  file.symlink:
    - target: {{ builder_github_dir }}
    - force: True
    - mode: 0755
    - makedirs: True

/home/user/.config/qubes-builder-github/builders.list:
  file.managed:
    - mode: 0644
    - user: user
    - contents: |
{%- for builder in builders_list %}
        r{{ salt['pillar.get']('build-infra:build-envs:'+ env + ':builders-list:' + builder + ':release') }}={{ builder_dir }}={{ builder }}/builder.yml
{%- endfor %}
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
{{import_master_key}}:
  cmd.run:
    - runas: user
    - onchange:
      - file: /home/user/qubes-master-key.asc

{{qubes_master_key_fpr}}:
  gpg.present:
    - user: user
    - require:
      - cmd: {{import_master_key}}

'echo {{qubes_master_key_fpr}}:6 | gpg --import-ownertrust && gpg --check-trustdb':
  cmd.run:
    - runas: user
    - require:
      - gpg: {{qubes_master_key_fpr}}

/home/user/qubes-developers-keys.asc:
  file.managed:
    - source: salt://build-infra/qubes-builder/qubes-developers-keys.asc
    - user: user

gpg --import /home/user/qubes-developers-keys.asc:
  cmd.run:
    - runas: user
    - onchange:
      - file: /home/user/qubes-developers-keys.asc

{{builder_maintainers_keyring}}:
  file.directory:
    - user: user
    - group: user
    - mode: 0700

{{builder_maintainers_keyring}}-import:
  cmd.run:
    - name: gpg --homedir {{builder_maintainers_keyring}} --import /home/user/qubes-developers-keys.asc
    - runas: user
    - require:
      - file: {{builder_maintainers_keyring}}
    - onchange:
      - file: /home/user/qubes-developers-keys.asc

'echo {{qubes_master_key_fpr}}:6 | gpg --homedir {{builder_maintainers_keyring}} --import-ownertrust && gpg --homedir {{builder_maintainers_keyring}} --check-trustdb':
  cmd.run:
    - runas: user
    - require:
      - cmd: {{builder_maintainers_keyring}}-import

/home/user/builder-github.yml:
  file.managed:
    - source: salt://build-infra/builder-github.yml
    - template: jinja
    - user: user
    - mode: 0600

{% if salt['pillar.get']('build-infra:openqa_key') and salt['pillar.get']('build-infra:openqa_secret') %}
/home/user/.config/openqa/client.conf:
  file.managed:
    - source: salt://build-infra/openqa-client.conf
    - makedirs: True
    - template: jinja
    - user: user
    - mode: 0600
{% endif %}

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

/home/user/.config/systemd/user/upload-release-status.service:
  file.managed:
    - contents: |
        [Service]
        ExecStart={{builder_github_dir}}/utils/upload-release-status
    - mode: 0644
    - user: user
    - makedirs: true

/home/user/.config/systemd/user/upload-release-status.timer:
  file.managed:
    - source: salt://build-infra/upload-release-status.timer
    - mode: 0644
    - user: user
    - makedirs: true

/home/user/.config/systemd/user/timers.target.wants/upload-release-status.timer:
  file.symlink:
    - target: ../upload-release-status.timer
    - force: True
    - mode: 0755
    - makedirs: True

commands-keyring:
  cmd.run:
    - name: rm -f {{ commands_keyring }}; LC_ALL=C.utf8 gpg2 --dearmor > {{ commands_keyring }} < /home/user/trusted-keys-for-commands.asc
    - runas: user
    - onchange:
      - file: /home/user/trusted-keys-for-commands.asc

/home/user/.ssh/config:
  file.managed:
    - user: user
    - contents: |
{% for host, config in salt['pillar.get']('build-infra:remote-hosts', {}).items() %}
        Host {{host}}
          HostName {{host}}
          User {{config.ssh_user}}
{% endfor %}
    - mode: 0755
    - makedirs: True

{% for host, config in salt['pillar.get']('build-infra:remote-hosts', {}).items() %}
{{host}}:
  ssh_known_hosts.present:
    - user: user
    - enc: {{config.ssh_host_enc}}
    - key: {{config.ssh_host_key}}
    - hash_known_hosts: False
{% endfor %}

github.com:
  ssh_known_hosts.present:
    - user: user
    - enc: ssh-rsa
    - key: AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
    - hash_known_hosts: False

{% if salt['pillar.get']('build-infra:mirror_ssh_key') %}
/home/user/.ssh/id_rsa:
  file.managed:
    - contents_pillar: build-infra:mirror_ssh_key
    - mode: 600
    - user: user
    - group: user
    - makedirs: True
    - dir_mode: 700
{% endif %}

builder-checkout:
  cmd.script:
    - source: salt://build-infra/safe-checkout-sha
    - args: "-- https://github.com/QubesOS/qubes-builderv2 {{ builder_dir }} f5576c895d0f2c35b3b8751f0d5cde0329c7fe3a"
    - runas: user
    - creates: {{builder_dir}}


builder-github-checkout:
  cmd.script:
    - source: salt://build-infra/safe-checkout-sha
    - args: "-- https://github.com/QubesOS/qubes-builderv2-github {{ builder_github_dir }} 9d19606bc6b6aecd164d51c57b522fedace09235"
    - runas: user
    - creates: {{builder_github_dir}}


{% for builder in builders_list %}
{% set config_baseurl = salt['pillar.get']('build-infra:build-envs:' + env + ':builders-list:' + builder + ':config:repository:baseurl', 'https://github.com/QubesOS/qubes-') %}
{% set config_repo = salt['pillar.get']('build-infra:build-envs:' + env + ':builders-list:' + builder + ':config:repository:component', 'release-configs') %}
{% set config_branch = salt['pillar.get']('build-infra:build-envs:' + env + ':builders-list:' + builder + ':config:repository:branch', 'master') %}
{% set config_file = salt['pillar.get']('build-infra:build-envs:' + env + ':builders-list:' + builder + ':config:file') %}
{% set keys =  salt['pillar.get']('build-infra:build-envs:' + env + ':builders-list:' + builder + ':keys', []) %}

{{builder}}:
  file.directory:
    - user: user
    - group: user

{{builder}}/builder-config.yml:
  file.managed:
    - source: salt://build-infra/builder-config.yml
    - makedirs: True
    - template: jinja
    - user: user
    - group: user
    - context:
        config_baseurl: {{config_baseurl.split('/')[:3]|join('/')}}
        config_prefix: {{config_baseurl.split('/')[3:]|join('/')}}
        config_component: {{config_repo}}
        config_branch: {{config_branch}}
        builder: {{builder}}

{{builder}}-init:
  cmd.run:
    - name: "./qb --builder-conf={{builder}}/builder-config.yml -c {{config_repo}} package fetch"
    - cwd: {{ builder_dir }}
    - runas: user
    - require:
      - cmd: builder-checkout
      - file: {{builder}}/builder-config.yml

{{builder}}/builder.yml:
  file.managed:
    - contents: |
        include:
        - sources/{{config_repo}}/{{config_file}}
        - /home/user/builder-github.yml
        artifacts-dir: {{builder}}
        executor:
          type: qubes
          options:
            dispvm: builder-dvm
    - mode: 0644
    - require:
      - cmd: {{builder}}-init

{% endfor %}
