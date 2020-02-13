{% set build_logs_key_fpr = salt['pillar.get']('build-infra:build_logs_key_fpr', '1B760CED53D8EB5AE529BEBB16D7539A228D30DB') %}
{% set build_logs_repo_url = 'git@github.com:' + salt['pillar.get']('build-infra:build_logs_repo', 'QubesOS/build-logs') %}
{% set build_bot_name = salt['pillar.get']('build-infra:build_bot_name', 'Qubes OS build bot') %}
{% set build_bot_email = salt['pillar.get']('build-infra:build_bot_email', 'builder-bot@qubes-os.org') %}

# logs signing key, secret key is needed too (not configured through salt)
/home/user/qubes-build-log-key.asc:
  file.managed:
    - contents_pillar: build-infra:build_logs_repo_public_key
    - user: user

gpg --import /home/user/qubes-build-log-key.asc:
  cmd.run:
    - runas: user
    - onchange:
      - file: /home/user/qubes-build-log-key.asc

{{build_logs_key_fpr}}:
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
      - gpg: {{build_logs_key_fpr}}

echo {{build_logs_key_fpr}}:6 | gpg --import-ownertrust:
  cmd.run:
    - runas: user
    - require:
      - gpg: {{build_logs_key_fpr}}

/home/user/.ssh/id_rsa:
  file.managed:
    - contents_pillar: build-infra:github_ssh_key
    - mode: 600
    - user: user
    - group: user
    - makedirs: True
    - dir_mode: 700

github.com:
  ssh_known_hosts.present:
    - user: user
    - enc: ssh-rsa
    - key: AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
# Disable for now because of Salt bug 37948
    - hash_known_hosts: False

{{build_logs_repo_url}}:
  git.latest:
    - target: /home/user/QubesIncomingBuildLog
    - user: user

# verify head commit
git verify-commit --raw HEAD 2>&1 >/dev/null | grep '^\[GNUPG:\] TRUST_ULTIMATE':
  cmd.run:
    - cwd: /home/user/QubesIncomingBuildLog
    - runas: user
    - require:
      - git: {{build_logs_repo_url}}
      - gpg: {{build_logs_key_fpr}}

/usr/local/etc/qubes-rpc/qubesbuilder.BuildLog:
  file.managed:
    - source: salt://build-infra/qubes-builder/rpc-services/qubesbuilder.BuildLog
    - mode: 0775
    - makedirs: True

{% load_yaml as git_config -%}
user.name: {{build_bot_name}}
user.email: {{build_bot_email}}
user.signingkey: {{build_logs_key_fpr}}
commit.gpgsign: true
gpg.program: gpg2
{%- endload %}

{% for name, value in git_config.items() %}
git-config-{{name}}:
  git.config_set:
    - name: {{name}}
    - value: {{value}}
    - user: user
    - global: True
{% endfor %}
