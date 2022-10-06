qubes-infrastructure-mirrors:
  file.recurse:
    - name: /home/user/qubes-mirrors
    - source: salt://build-infra/qubes-infrastructure-mirrors
    - user: user
  cmd.run:
    - name: python3 setup.py install --user
    - runas: user
    - cwd: /home/user/qubes-mirrors
    - onchanges:
      - file: qubes-infrastructure-mirrors

