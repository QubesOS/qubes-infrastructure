build-logs:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:logs-template', 'fedora-29') }}
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
      - template: {{ salt['pillar.get']('build-infra:build-template', 'fedora-29') }}
      - netvm: {{ salt['pillar.get']('build-infra:build-netvm', 'sys-whonix') }}

keys-{{env}}:
  qvm.vm:
    - present:
      - label: black
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:keys-template', 'fedora-29-minimal') }}
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

/etc/qubes-rpc/qubesbuilder.ExportDisk:
  file.managed:
    - source: salt://build-infra/qubes-builder/rpc-services/qubesbuilder.ExportDisk
    - mode: 0755
    - makedirs: True

/etc/qubes-rpc/qubesbuilder.AttachDisk:
  file.managed:
    - source: salt://build-infra/qubes-builder/rpc-services/qubesbuilder.AttachDisk
    - mode: 0755
    - makedirs: True

/etc/qubes-rpc/policy/qubesbuilder.AttachDisk:
  file.managed:
    - source: salt://build-infra/qubes-builder/rpc-services/policy/qubesbuilder.AttachDisk
    - mode: 0664
    - makedirs: True

/etc/qubes-rpc/policy/qubesbuilder.ExportDisk:
  file.managed:
    - mode: 0664
    - makedirs: True
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', []) %}
      - build-{{env}} dom0 allow
{% endfor %}

/etc/qubes-rpc/policy/qubesbuilder.CopyTemplateBack:
  file.managed:
    - mode: 0664
    - makedirs: True
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', []) %}
      - $anyvm build-{{env}} allow
{% endfor %}
