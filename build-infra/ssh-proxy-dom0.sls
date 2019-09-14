{% for host in ['github.com', 'yum.qubes-os.org', 'deb.qubes-os.org'] %}
/etc/qubes-rpc/policy/local.ConnectSSH+{{host}}:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
        - build-{{env}} sys-net allow
{% endfor %}

{% endfor %}

/etc/qubes-rpc/policy/local.ConnectSSH:
  file.managed:
    - makedirs: True
    - contents:
      - $anyvm $anyvm deny
