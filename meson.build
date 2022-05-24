project('inary', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)

dependencies = [
    dependency('libarchive'),
    dependency('gio-2.0'),
]

sources = files('src/util/archive.vala',
                'src/util/logger.vala',
               )
if get_option('enable_debug')
    add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

if get_option('static')
    slib = static_library('inary-static', sources, dependencies: dependencies)
    executable('inary-static','src/main.vala', dependencies: dependencies, link_args: ['-static'], link_with: slib)
else
    lib = library('inary', sources, dependencies: dependencies)
    executable('inary', 'src/main.vala', dependencies: dependencies, link_with: lib)
    executable('inary-test', 'src/test.vala', dependencies: dependencies, link_with: lib)
endif

