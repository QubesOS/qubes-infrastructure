/rw/config/webhooks.nginx:
  file.managed:
    - source: salt://build-infra/webhooks.nginx
    - user: root
    - mode: 0644

/rw/config/rc.local:
  file.blockreplace:
    - marker_start: '### webhooks start ###'
    - marker_end: '### webhooks_end ###'
    - append_if_not_found: True
    - source: salt://build-infra/webhooks.rc-local

rc.local-executable:
  file.managed:
    - name: /rw/config/rc.local
    - replace: False
    - mode: 0755

