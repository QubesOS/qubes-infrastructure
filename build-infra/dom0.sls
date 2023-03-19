{% set any_builderv1 = salt['pillar.get']('build-infra:build-envs', {}).values() | selectattr('builderv2', 'undefined') | list %}
{% set any_builderv2 = salt['pillar.get']('build-infra:build-envs', {}).values() | selectattr('builderv2', 'defined') | list %}

{% if any_builderv2 %}
builder-dvm:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:build-template', 'fedora-37') }}
      - netvm: {{ salt['pillar.get']('build-infra:build-netvm', 'sys-whonix') }}
      - dispvm-allowed: True

volume-builder-dvm:
  cmd.run:
    - name: 'qvm-volume extend builder-dvm:private 30GiB'
{% endif %}

### This block is executed for each logs environment
{%- for log in salt['pillar.get']('build-infra:build-envs', {}).values()|list|map(attribute='logs')|unique|list %}
{{log}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:logs-template', 'fedora-37') }}
      - netvm: {{ salt['pillar.get']('build-infra:logs-netvm', 'sys-firewall') }}
{%- endfor %}

### This block is executed for each build environment
{% for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}

build-{{env}}:
  qvm.vm:
    - present:
      - label: green
    - prefs:
      - template: {{ salt['pillar.get']('build-infra:build-template', 'fedora-37') }}
      - netvm: {{ salt['pillar.get']('build-infra:build-netvm', 'sys-whonix') }}
{% if salt['pillar.get']('build-infra:build-envs:' + env + ':builderv2', False) %}
      - default-dispvm: builder-dvm
{% endif %}

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
      - template: {{ salt['pillar.get']('build-infra:keys-template', 'fedora-37-minimal') }}
      - netvm: none

{% endfor %}

###

/etc/qubes/policy.d/20-qubesbuilder.policy:
  file.managed:
    - contents: |
{%- if any_builderv1 %}
        qubesbuilder.AttachDisk * @anyvm dom0 allow
{%- endif %}
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
{%- set logvm = salt['pillar.get']('build-infra:build-envs:' + env + ':logs') %}
        qubesbuilder.LogReceived +build-{{env}} {{logvm}} dom0 allow target=keys-{{env}}
        qubes.Gpg * build-{{env}} keys-{{env}} allow
        qubes.Gpg * build-{{env}} @default allow target=keys-{{env}}
        qubes.Gpg * @anyvm keys-{{env}} deny
        qubesbuilder.BuildLog * build-{{env}} dom0 allow target={{logvm}}
{%- if salt['pillar.get']('build-infra:build-envs:' + env + ':builderv2', False) %}
        admin.vm.CreateDisposable * build-{{env}} dom0 allow
        
        admin.vm.Start * build-{{env}} @tag:disp-created-by-build-{{env}} allow target=dom0
        admin.vm.Kill * build-{{env}} @tag:disp-created-by-build-{{env}} allow target=dom0
        
        qubesbuilder.FileCopyIn * build-{{env}} @tag:disp-created-by-build-{{env}} allow
        qubesbuilder.FileCopyOut * build-{{env}} @tag:disp-created-by-build-{{env}} allow
        
        qubes.WaitForSession * build-{{env}} @tag:disp-created-by-build-{{env}} allow
        qubes.VMShell * build-{{env}} @tag:disp-created-by-build-{{env}} allow
{%- else %}
        qubesbuilder.ExportDisk * build-{{env}} dom0 allow
        qubesbuilder.CopyTemplateBack * @anyvm build-{{env}} allow
{%- endif %}
{%- endfor %}

{% if any_builderv1 %}
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
{% endif %}
