{% set env = grains['id']|replace('keys-','') %}
{% set is_builderv2 = salt['pillar.get']('build-infra:build-envs:' + env + ':builderv2', False) %}

/usr/local/etc/qubes-rpc/qubesbuilder.LogReceived:
  file.managed:
    - contents: |
        #!/bin/sh
        touch /run/qubes-gpg-split/stat.$1
    - mode: 0755
    - makedirs: True

{% if is_builderv2 %}
/home/user/.profile:
  file.append:
    # 1 year, basically forever, as builderv2 has much better isolation on its
    # own
    - text: "export QUBES_GPG_AUTOACCEPT=31536000"
{% endif %}
