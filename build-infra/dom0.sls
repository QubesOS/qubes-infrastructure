build-logs:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:logs-template', 'fedora-24') }}
      - netvm: {{ salt['pillar.get']('build-infra:logs-netvm', 'sys-firewall') }}

/etc/qubes-rpc/policy/qubes.Gpg:
  file.prepend:
    - text:
{%- for env in salt['pillar.get']('build-infra:build-envs', []) %}
      - build-{{env}} keys-{{env}} allow
      - $anyvm keys-{{env}} deny
{% endfor %}


### This block is executed for each build environment

{% for env in salt['pillar.get']('build-infra:build-envs', []) %}

build-{{env}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:build-template', 'fedora-24') }}
      - netvm: {{ salt['pillar.get']('build-infra:build-netvm', 'sys-whonix') }}

keys-{{env}}:
  qvm.vm:
    - present:
      - label: black
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:keys-template', 'fedora-24-minimal') }}
      - netvm: none

/etc/qubes-rpc/policy/qubesbuilder.LogReceived+build-{{env}}:
  file.managed:
    - contents:
      - build-logs dom0 allow,target=keys-{{env}}

{% endfor %}

###

/etc/qubes-rpc/policy/qubesbuilder.BuildLog:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', []) %}
      - build-{{env}} dom0 allow,target=build-logs
{% endfor %}
