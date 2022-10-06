/etc/qubes/policy.d/20-qubesbuilder-webhook.policy:
  file.managed:
    - contents:
{%- for env in salt['pillar.get']('build-infra:build-envs', {}).keys() %}
       - qubesbuilder.TriggerBuild * {{ salt['pillar.get']('build-infra:netvm', 'sys-net') }} build-{{env}} allow
       - qubesbuilder.ProcessGithubCommand * {{ salt['pillar.get']('build-infra:netvm', 'sys-net') }} build-{{env}} allow
{% endfor %}
    - group: qubes
    - mode: 0664
