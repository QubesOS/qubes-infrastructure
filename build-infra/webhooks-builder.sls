/home/user/webhooks/trigger_build.py:
  file.managed:
    - source: salt://build-infra/qubes-builder-github/github-webhooks/trigger-build
    - mode: 0755
    - user: user

/home/user/webhooks/process_comment.py:
  file.managed:
    - source: salt://build-infra/qubes-builder-github/github-webhooks/process-comment
    - mode: 0755
    - user: user

/home/user/.config/qubes-builder-github/build-vms.list:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', []) %}
       - build-{{env}}
{% endfor %}
    - mode: 0644
    - makedirs: True
    - user: user
