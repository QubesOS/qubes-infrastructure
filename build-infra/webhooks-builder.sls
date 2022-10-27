/home/user/webhooks:
  file.recurse:
    - source: salt://build-infra/qubes-builderv2-github/webhooks
    - user: user
    - group: user
    - file_mode: keep

/home/user/.config/qubes-builder-github/build-vms.list:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
       - build-{{env}}
{% endfor %}
    - mode: 0644
    - makedirs: True
    - user: user
