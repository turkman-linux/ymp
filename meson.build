project('ymp', 'vala', 'c',
    version : '1.0',
    license: ['GplV3']

)
run_command('bash', './tool/check.sh', meson.current_build_dir(), check:true)
args = ['-X','-O3', '-flto', '-DSULIX', '-Wall']

args += ['-s', '-Wl,--gc-sections','-ffunction-sections', '-fdata-sections', '-fno-exceptions']

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
        'find src -type f -iname "*.vala" | sort -V | bash ./tool/mkdoc.sh > src/libymp.md',
        check:true)
endif


sources = files('src/ymp.vala',
                'src/color.vala',
                'src/settings.vala',
                'src/wslblock.vala',
                'src/ccode.vala',
                'ctx.vala',
               )

sources += run_command('find', 'src/util','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/operations','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/data','-type','f',check:true).stdout().strip().split('\n')

add_project_arguments(['--pkg', 'posix'], language: 'vala')
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
    if get_option('static')
        args +=[run_command('pkg-config', '--libs', '--static','libcurl',check:true).stdout().strip()]
    else
        args +=[run_command('pkg-config', '--libs', 'libcurl',check:true).stdout().strip()]
    endif
else
    add_project_arguments('-D', 'no_libcurl', language: 'vala')
    args +=['-Dno_libcurl']
endif

if get_option('libreadline')
    dependencies += dependency('readline', static:get_option('static'))
else
    add_project_arguments('-D', 'no_libreadline', language: 'vala')
endif

if get_option('static')
    lib = static_library('ymp', sources, dependencies: dependencies, link_args: args)
    args += ['-static']
else
    lib = library('ymp', sources, dependencies: dependencies, link_args: args)
endif
if get_option('tools')
    executable('ymp-cli', 'src/ymp-cli.vala', dependencies: dependencies, link_args: args, link_with: lib)
    install_data(meson.current_build_dir() / 'ymp-cli', install_dir : get_option('bindir'),rename : 'ymp')
endif
if get_option('scripts')
    foreach script : run_command('find', 'scripts','-type','f',check:true).stdout().strip().split('\n')
        install_data(script, install_dir : get_option('bindir'))
    endforeach
endif
install_data('data/ymp.conf', install_dir : get_option('sysconfdir'), rename : 'ymp.conf')
install_data('data/application-x-ymp.svg', install_dir : get_option('prefix') / 'share/icons/hicolor/scalable/mimetypes/')
install_data('data/ymp-mime.xml', install_dir : get_option('prefix') / 'share/mime/application/')
if get_option('static')
    install_data(meson.current_build_dir() / 'libymp.a', install_dir : get_option('libdir'))
else
    install_data(meson.current_build_dir() / 'libymp.so', install_dir : get_option('libdir'))
endif
install_data(meson.current_build_dir() / 'obj.o', install_dir : get_option('libdir'), rename : 'empty.o')
install_data(meson.current_build_dir() / 'ymp.h', install_dir : get_option('includedir'), rename : 'ymp.h')
if get_option('test')
    # Test binary
    executable('ymp-test', 'test/test.vala', dependencies: dependencies, link_args: args, link_with: lib)
endif

