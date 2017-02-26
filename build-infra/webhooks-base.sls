/home/user/webhooks:
  file.directory:
    - user: user
    - group: user
    - mode: 0700
    - makedirs: True

/home/user/webhooks/fcgi-wrapper:
  file.managed:
    - source: salt://build-infra/fcgi-wrapper
    - user: user
    - mode: 0755

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

/rw/config/webhooks.service:
  file.managed:
    - source: salt://build-infra/webhooks.service
    - user: root
    - mode: 0644

/rw/config/webhooks.socket:
  file.managed:
    - source: salt://build-infra/webhooks.socket
    - user: root
    - mode: 0644

rc.local-executable:
  file.managed:
    - name: /rw/config/rc.local
    - replace: False
    - mode: 0755

