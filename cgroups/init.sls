#!pydsl

if __grains__['os'] == 'Ubuntu':

    created_mountpoints = []
    for groupkey, groupval in __pillar__['cgroups'].items():
        mountpoint = groupval['mountpoint_root']
        if mountpoint not in created_mountpoints:
            created_mountpoints.append(mountpoint)
            state("cgroups|mountpoint_root|{root}".format(
                root=mountpoint,
            )).file.directory(
                name=mountpoint,
            )

    packages_state = state('cgroups|packages')
    packages_state.pkg.installed(
        pkgs=[
            'cgroup-lite',
            'cgroup-bin',
            'libcgroup1',
        ],
    )

    cgroup_lite_service_state = state('cgroups|cgroup-lite-service')
    cgroup_lite_service_state.service.running(
        name='cgroup-lite',
        enable=True,
    ).require(packages_state.pkg)

    cgrulesengd_state = state('cgroups|cgrulesengd-service')
    cgrulesengd_state.file.managed(
        name='/etc/init/cgrulesengd.conf',
        source='salt://cgroups/files/cgrulesengd.upstart',
        template='jinja',
        mode=0644,
    )

    cgconfig_state = state('cgroups|cgrulesengd-service|cgconfig')
    cgconfig_state.file.managed(
        name='/etc/cgconfig.conf',
        source='salt://cgroups/files/cgconfig.conf',
        template='jinja',
    )

    cgrules_state = state('cgroups|cgrulesengd-service|cgrules')
    cgrules_state.file.managed(
        name='/etc/cgrules.conf',
        source='salt://cgroups/files/cgrules.conf',
        template='jinja',
    )

    cgrulesengd_state.service.running(
        name='cgrulesengd',
        enable=True,
    ).watch(
        cgrulesengd_state.file,
        cgconfig_state.file,
        cgrules_state.file,
        cgroup_lite_service_state.service,
    )
