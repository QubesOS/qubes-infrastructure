webhook-dependencies:
  pkg.installed:
    - pkgs:
      - nginx
      - uwsgi
      - uwsgi-plugin-python3
      - python3-flask
      - nmap-ncat