{% set build_log_key_fpr = '1B760CED53D8EB5AE529BEBB16D7539A228D30DB' %}

# logs signing key, secret key is needed too (not configured through salt)
{{build_log_key_fpr}}:
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
      - gpg: {{build_log_key_fpr}}

echo {{build_log_key_fpr}}:6 | gpg --import-ownertrust:
  cmd.run:
    - runas: user
    - requires:
      - gpg: {{build_log_key_fpr}}

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

'git@github.com:QubesOS/build-logs':
  git.latest:
    - target: /home/user/QubesIncomingBuildLog
    - user: user

# verify head commit
git verify-commit --raw HEAD 2>&1 >/dev/null | grep '^\[GNUPG:\] TRUST_ULTIMATE':
  cmd.run:
    - cwd: /home/user/QubesIncomingBuildLog
    - runas: user
    - requires:
      - git: 'git@github.com:QubesOS/build-logs'
      - gpg: {{build_log_key_fpr}}

/usr/local/etc/qubes-rpc/qubesbuilder.BuildLog:
  file.managed:
    - source: salt://build-infra/qubes-builder/rpc-services/qubesbuilder.BuildLog
    - mode: 0775
    - makedirs: True


{% load_yaml as git_config -%}
user.name: Qubes OS build bot
user.email: builder-bot@qubes-os.org
user.signingkey: {{build_log_key_fpr}}
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
