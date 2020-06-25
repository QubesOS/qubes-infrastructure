{% set hosts = ['github.com'] %}
{% for host in salt['pillar.get']('build-infra:remote-hosts', {}).keys() %}
{% do hosts.append(host) %}
{% endfor %}

{% for host in hosts %}
/etc/qubes-rpc/policy/local.ConnectSSH+{{host}}:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
        - build-{{env}} {{ salt['pillar.get']('build-infra:netvm', 'sys-net') }} allow
{% endfor %}

{% endfor %}

/etc/qubes-rpc/policy/local.ConnectSSH:
  file.managed:
    - makedirs: True
    - contents:
      - $anyvm $anyvm deny
