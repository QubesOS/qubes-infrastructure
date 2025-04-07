{% for srv in ["QueryKey", "CreateKey", "DeleteKey", "GetCert", "Sign"] %}
/usr/local/etc/qubes-rpc/qubesbuilder.WinSign.{{srv}}:
  file.managed:
    - source: salt://build-infra/qubes-builderv2/rpc/qubesbuilder.WinSign.{{srv}}
    - mode: 0775
    - makedirs: True
{% endfor %}
/usr/local/etc/qubes-rpc/qubesbuilder.WinSign.common:
  file.managed:
    - source: salt://build-infra/qubes-builderv2/rpc/qubesbuilder.WinSign.common
    - mode: 0644
    - makedirs: True
