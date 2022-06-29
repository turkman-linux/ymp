project('inary', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)
run_command('bash', './tool/check.sh', meson.current_build_dir())
args = ['-X','-O3', '-flto', '-Dsulin', '-Wall']

args += ['-X', '-s', '-Wl,--gc-sections','-ffunction-sections', '-fdata-sections', '-fno-exceptions']

dependencies = [
    dependency('gio-2.0', static:get_option('static')),
    dependency('readline', static:get_option('static')),
]

add_project_arguments(['--disable-assert', '--hide-internal', '--nostdpkg', '--enable-checking', '--abi-stability'], language: 'vala')
add_project_arguments('-D', '_GNU_SOURCE', '--disable-version-header', language: 'vala')

run_command('bash', './tool/mkctx.sh',
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    'VERSION='+meson.project_version(),
    check:true)

if get_option('doc')
    run_command('bash', '-c',
        'find src -type f -iname "*.vala" | sort -V | bash ./tool/mkdoc.sh > src/libinary.md',
        check:true)
endif


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

if not get_option('ignore-oem')
    add_project_arguments('-D', 'check_oem', language: 'vala')
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
if get_option('tools')
    foreach tool: run_command('find', 'src/tools','-type','f',check:true).stdout().strip().split('\n')
        name = run_command('basename', tool, check:true).stdout().split('.')[0]
        executable(name, tool, dependencies: dependencies, link_args: args, link_with: lib)
        install_data(meson.current_build_dir() / name, install_dir : get_option('bindir'))
    endforeach
endif
install_data('data/inary.conf', install_dir : get_option('sysconfdir'), rename : 'inary.conf')
if get_option('static')
    install_data(meson.current_build_dir() / 'libinary.a', install_dir : get_option('libdir'))
else
    install_data(meson.current_build_dir() / 'libinary.so', install_dir : get_option('libdir'))
endif
install_data(meson.current_build_dir() / 'obj.o', install_dir : get_option('libdir'), rename : 'empty.o')
install_data(meson.current_build_dir() / 'inary.h', install_dir : get_option('includedir'), rename : 'inary.h')
# Test binary
executable('inary-test', 'test/test.vala', dependencies: dependencies, link_args: args, link_with: lib)

