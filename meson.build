project('inary', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)

dependencies = [
    dependency('gio-2.0'),
    dependency('readline'),
]
run_command('bash', './mkctx.sh', 
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    check:true)

sources = files('src/inary.vala',
                'src/color.vala',
                'src/settings.vala',
                'ctx.vala',
               )
sources += run_command('find', 'src/util','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/operations','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/data','-type','f',check:true).stdout().strip().split('\n')


add_project_arguments('--pkg', 'posix', language: 'vala')

if get_option('debug')
    add_project_arguments('--debug', language: 'vala')
    add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

if not get_option('colorize')
    add_project_arguments('-D', 'NOCOLOR', language: 'vala')
endif


if get_option('libarchive')
    dependencies += dependency('libarchive')
else
    add_project_arguments('-D', 'no_libarchive', language: 'vala')
endif

if get_option('libreadline')
    dependencies += dependency('readline')
else
    add_project_arguments('-D', 'no_libareadline', language: 'vala')
endif

if get_option('static')
    slib = static_library('inary-static', sources, dependencies: dependencies)
    executable('inary-static','src/main.vala', dependencies: dependencies, link_args: ['-static'], link_with: slib)
else
    lib = library('inary', sources, dependencies: dependencies)
    executable('inary', 'src/main.vala', dependencies: dependencies, link_with: lib)
    executable('iniget', 'src/tools/iniget.vala', dependencies: dependencies, link_with: lib)
    executable('yamlget', 'src/tools/yamlget.vala', dependencies: dependencies, link_with: lib)
    executable('extract', 'src/tools/extract.vala', dependencies: dependencies, link_with: lib)
    executable('inarysh', 'src/tools/inarysh.vala', dependencies: dependencies, link_with: lib)
    executable('inary-test', 'test/test.vala', dependencies: dependencies, link_with: lib)
endif
