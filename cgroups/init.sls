{% set os = grains['os'] %}

{% if os == 'Ubuntu' %}

cgroups|packages:
  pkg.installed:
    - pkgs:
      - cgroup-bin
      - cgroup-lite
      - libcgroup1

cgroups|cgroup-lite-service:
  service.running:
    - name: cgroup-lite
    - enable: True

cgroups|cgrulesengd-service:
  file.managed:
    - name: /etc/init/cgrulesengd.conf
    - source: salt://cgroups/files/cgrulesengd.upstart
    - template: jinja
    - mode: 0644

  service.running:
    - name: cgrulesengd
    - enable: True
    - watch:
      - file: cgroups|cgrulesengd-service
      - file: cgroups|cgrulesengd-service|cgconfig
      - file: cgroups|cgrulesengd-service|cgrules
      - service: cgroups|cgroup-lite-service

cgroups|cgrulesengd-service|cgconfig:
  file.managed:
    - name: /etc/cgconfig.conf
    - source: salt://cgroups/files/cgconfig.conf
    - template: jinja

cgroups|cgrulesengd-service|cgrules:
  file.managed:
    - name: /etc/cgrules.conf
    - source: salt://cgroups/files/cgrules.conf
    - template: jinja

{% endif %}
