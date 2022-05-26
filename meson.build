project('inary', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)

dependencies = [
    dependency('gio-2.0'),
]

sources = files('src/inary.vala',
                'src/util/archive.vala',
                'src/util/command.vala',
                'src/util/logger.vala',
                'src/util/file.vala',
                'src/util/iniparser.vala',
                'src/util/yamlparser.vala',
                'src/settings.vala',
                'ctx.vala',
               )
glob = run_command('find', 'src/operations','-type','f')
sources += glob.stdout().strip().split('\n')


run_command('bash', './mkctx.sh', 
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    check:true)


add_project_arguments('--pkg', 'posix', language: 'vala')

if get_option('debug')
    add_project_arguments('--debug', language: 'vala')
    add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

if not get_option('colorize')
    add_project_arguments('-D', 'NOCOLOR', language: 'vala')
endif


if get_option('no_libarchive')
    add_project_arguments('-D', 'no_libarchive', language: 'vala')
else
    dependencies += dependency('libarchive')
endif

if get_option('static')
    slib = static_library('inary-static', sources, dependencies: dependencies)
    executable('inary-static','src/main.vala', dependencies: dependencies, link_args: ['-static'], link_with: slib)
else
    lib = library('inary', sources, dependencies: dependencies)
    executable('inary', 'src/main.vala', dependencies: dependencies, link_with: lib)
    executable('iniget', 'src/tools/iniget.vala', dependencies: dependencies, link_with: lib)
    executable('yamlget', 'src/tools/yamlget.vala', dependencies: dependencies, link_with: lib)
    executable('inarysh', 'src/tools/inarysh.vala', dependencies: dependencies, link_with: lib)
    executable('inary-test', 'test/test.vala', dependencies: dependencies, link_with: lib)
endif
