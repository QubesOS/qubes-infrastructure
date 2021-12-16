### This block is executed for each logs environment
{%- for log in salt['pillar.get']('build-infra:build-envs', {}).values()|list|map(attribute='logs')|unique|list %}
{{log}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:logs-template', 'fedora-34') }}
      - netvm: {{ salt['pillar.get']('build-infra:logs-netvm', 'sys-firewall') }}
{%- endfor %}

### This block is executed for each build environment
{% for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}

build-{{env}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:build-template', 'fedora-34') }}
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
      - template: {{ salt['pillar.get']('build-infra:keys-template', 'fedora-34-minimal') }}
      - netvm: none

/etc/qubes-rpc/policy/qubesbuilder.LogReceived+build-{{env}}:
  file.managed:
    - contents:
      - {{salt['pillar.get']('build-infra:build-envs:' + env + ':logs')}} dom0 allow,target=keys-{{env}}

{% endfor %}

###

/etc/qubes-rpc/policy/qubes.Gpg:
  file.prepend:
    - text:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
      - build-{{env}} keys-{{env}} allow
      - $anyvm keys-{{env}} deny
{% endfor %}

/etc/qubes-rpc/policy/qubesbuilder.BuildLog:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
      - build-{{env}} dom0 allow,target={{salt['pillar.get']('build-infra:build-envs:' + env + ':logs')}}
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
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
      - build-{{env}} dom0 allow
{% endfor %}

/etc/qubes-rpc/policy/qubesbuilder.CopyTemplateBack:
  file.managed:
    - mode: 0664
    - makedirs: True
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
      - $anyvm build-{{env}} allow
{% endfor %}
