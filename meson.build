project('inary', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)

dependencies = [
    dependency('gio-2.0'),
]

sources = files('src/util/archive.vala',
                'src/util/command.vala',
                'src/util/logger.vala',
                'src/util/file.vala',
                'src/util/iniparser.vala',
               )

add_project_arguments('--pkg', 'posix', language: 'vala')

if get_option('enable_debug')
    add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

if get_option('no_libarchive')
    add_project_arguments('-D', 'no_libarchive', language: 'vala')
else
    dependencies += dependency('libarchive')
endif

slib = static_library('inary-static', sources, dependencies: dependencies)
lib = library('inary', sources, dependencies: dependencies)
if get_option('static')
    executable('inary-static','src/main.vala', dependencies: dependencies, link_args: ['-static'], link_with: slib)
endif
executable('inary', 'src/main.vala', dependencies: dependencies, link_with: lib)
executable('inary-test', 'src/test.vala', dependencies: dependencies, link_with: lib)

