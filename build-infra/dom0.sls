### This block is executed for each logs environment
{%- for log in salt['pillar.get']('build-infra:build-envs', {}).values()|list|map(attribute='logs')|unique|list %}
{{log}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:logs-template', 'fedora-33') }}
      - netvm: {{ salt['pillar.get']('build-infra:logs-netvm', 'sys-firewall') }}
{%- endfor %}

### This block is executed for each build environment
{% for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}

build-{{env}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:build-template', 'fedora-33') }}
      - netvm: {{ salt['pillar.get']('build-infra:build-netvm', 'sys-whonix') }}

{% if salt['pillar.get']('build-infra:build-envs:' + env + ':volume-size') %}
volume-{{env}}:
  cmd.run:
    - name: 'qvm-volume extend build-{{env}}:private {{salt['pillar.get']('build-infra:build-envs:' + env + ':volume-size')}}'
{% endif %}

keys-{{env}}:
  qvm.vm:
    - present:
      - label: black
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:keys-template', 'fedora-33-minimal') }}
      - netvm: none

{% endfor %}

###

/etc/qubes/policy.d/20-qubesbuilder.policy:
  file.managed:
    - contents: |
        qubesbuilder.AttachDisk * @anyvm dom0 allow
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
{%- set logvm = salt['pillar.get']('build-infra:build-envs:' + env + ':logs') %}
        qubesbuilder.LogReceived +build-{{env}} {{logvm}} dom0 allow target=keys+{{env}}
        qubes.Gpg * build-{{env}} keys-{{env}} allow
        qubes.Gpg * build-{{env}} @default allow target=keys-{{env}}
        qubes.Gpg * @anyvm keys-{{env}} deny
        qubesbuilder.BuildLog * build-{{env}} dom0 allow target={{logvm}}
        qubesbuilder.ExportDisk * build-{{env}} dom0 allow
        qubesbuilder.CopyTemplateBack * @anyvm build-{{env}} allow
{%- endfor %}

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
