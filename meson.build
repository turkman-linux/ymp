project('inary', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)

args = ['-X','-O3', '-flto']

args += ['-X', '-s', '-R', '.comment', '-R', '.gnu.version', '-Wl,--gc-sections','-ffunction-sections', '-fdata-sections', '-fno-exceptions']

dependencies = [
    dependency('gio-2.0', static:get_option('static')),
    dependency('readline', static:get_option('static')),
]
run_command('bash', './tool/mkctx.sh',
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    check:true)

run_command('bash', '-c',
            'find src -type f -iname "*.vala" | bash ./tool/mkdoc.sh > src/libinary.md',
    check:true)


sources = files('src/inary.vala',
                'src/color.vala',
                'src/settings.vala',
                'src/wslblock.vala',
                'src/ccode.vala',
                'ctx.vala',
               )

sources += run_command('find', 'src/util','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/operations','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/data','-type','f',check:true).stdout().strip().split('\n')

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

add_project_arguments(['--pkg', 'posix'], language: 'vala')
add_project_arguments(['--pkg', 'libcurl'], language: 'vala')
foreach csource : run_command('find', 'src/ccode','-type','f',check:true).stdout().strip().split('\n')
    args += [meson.current_source_dir() / csource]
endforeach

if get_option('debug')
    add_project_arguments('--debug', language: 'vala')
    add_project_arguments('-D', 'DEBUG', language: 'vala')
endif

if not get_option('colorize')
    add_project_arguments('-D', 'NOCOLOR', language: 'vala')
endif


if get_option('libarchive')
    dependencies += dependency('libarchive', static:get_option('static'))
else
    add_project_arguments('-D', 'no_libarchive', language: 'vala')
endif

if get_option('libcurl')
    dependencies += dependency('libcurl', static:get_option('static'))
    if get_option('libbrotli')
        args += ['-lbrotlicommon']
    endif
else
    add_project_arguments('-D', 'no_libcurl', language: 'vala')
endif

if get_option('libreadline')
    dependencies += dependency('readline', static:get_option('static'))
else
    add_project_arguments('-D', 'no_libreadline', language: 'vala')
endif

if get_option('static')
    lib = static_library('inary', sources, dependencies: dependencies, link_args: args)
    args += ['-X','-static']
else
    lib = library('inary', sources, dependencies: dependencies, link_args: args)
endif
executable('inary','src/tools/inary-cli.vala', dependencies: dependencies, link_args: args, link_with: lib)
if get_option('tools')
    foreach tool: run_command('find', 'src/tools','-type','f',check:true).stdout().strip().split('\n')
        name = run_command('basename', tool, check:true).stdout().split('.')[0]
        executable(name, tool, dependencies: dependencies, link_args: args, link_with: lib)
    endforeach
endif
executable('inary-test', 'test/test.vala', dependencies: dependencies, link_args: args, link_with: lib)

