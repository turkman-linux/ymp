project(
    'ymp',
    'vala', 'c',
    meson_version: '>= 0.49.0',
    version : '1.0',
    license: ['GplV3']
)
if meson.get_compiler('vala').version().version_compare('<0.54.9')
    error('vala compiler version 0.54.9 or newer is required.')
endif

run_command('bash', './tool/check.sh', meson.current_build_dir(), check:true)
args = ['-X','-O3', '-flto', '-DSULIX', '-Wall']

args += ['-s', '-Wl,--gc-sections','-ffunction-sections', '-fdata-sections', '-fno-exceptions']
if get_option('shared')
    shared_dependencies = [dependency('gio-2.0', static: false)]
endif

if get_option('static')
    static_dependencies = [dependency('gio-2.0', static: true)]
endif

add_project_arguments('-C', language: 'vala')
add_project_arguments(['--disable-assert', '--hide-internal', '--nostdpkg', '--enable-checking', '--abi-stability'], language: 'vala')
add_project_arguments('-D', '_GNU_SOURCE', '--disable-version-header', language: 'vala')
add_project_arguments(['--pkg', 'posix'], language: 'vala')


run_command('bash', './tool/mkctx.sh',
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    'DISTRODIR=/'+get_option('distrodir'),
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


foreach csource : run_command('find', 'src/ccode','-type','f',check:true).stdout().strip().split('\n')
    args += [meson.current_source_dir() / csource]
endforeach

if get_option('debug')
    add_project_arguments('--debug', language: 'vala')
    add_project_arguments('-D', 'DEBUG', language: 'vala')
    args += ['-DDEBUG', '-g']
endif

if not get_option('colorize')
    add_project_arguments('-D', 'NOCOLOR', language: 'vala')
endif

if not get_option('ignore-oem')
    add_project_arguments('-D', 'check_oem', language: 'vala')
endif

if get_option('libarchive')
    if get_option('shared')
        shared_dependencies += dependency('libarchive', static:false)
    endif
    if get_option('static')
        static_dependencies += dependency('libarchive', static:true)
    endif
else
    add_project_arguments('-D', 'no_libarchive', language: 'vala')
    args += ['-Dno_libarchive']
endif

if get_option('libcurl')
    if get_option('static')
        args += run_command('pkg-config', '--libs', '--static','libcurl',check:true).stdout().strip().split(' ')
    endif
    if get_option('shared')
        args += run_command('pkg-config', '--libs', 'libcurl',check:true).stdout().strip().split(' ')
    endif
    if get_option('libbrotli')
        args += ['-lbrotlicommon']
    endif

else
    add_project_arguments('-D', 'no_libcurl', language: 'vala')
    args +=['-Dno_libcurl']
endif

if get_option('libreadline')
    if get_option('shared')
        shared_dependencies += dependency('readline', static:false)
    endif
    if get_option('static')
        static_dependencies += dependency('readline', static:true)
    endif
else
    add_project_arguments('-D', 'no_libreadline', language: 'vala')
endif

if not get_option('shared') and not get_option('static')
    error('Build format not detected.\n=> Please Use -Dshared=true or -Dstatic=true')
endif

if get_option('shared')
    lib = library('ymp', sources, dependencies: shared_dependencies, link_args: args)
    install_data(meson.current_build_dir() / 'libymp.so', install_dir : get_option('libdir'), rename: 'libymp.so')
    if get_option('tools')
        executable('ymp-cli', 'src/ymp-cli.vala', dependencies: shared_dependencies, link_args: args, link_with: lib)
        install_data(meson.current_build_dir() / 'ymp-cli', install_dir : get_option('bindir'),rename : 'ymp')
    endif
    if get_option('test')
        executable('ymp-test', 'test/test.vala', dependencies: shared_dependencies, link_args: args, link_with: lib)
    endif
endif
if get_option('static')
    libstatic = static_library('ymp-static', sources, dependencies: static_dependencies, link_args: args + ['-static'])
    install_data(meson.current_build_dir() / 'libymp-static.a', install_dir : get_option('libdir'), rename: 'libymp.a')
    if get_option('tools')
        executable('ymp-cli-static', 'src/ymp-cli.vala', dependencies: static_dependencies, link_args: args + ['-static'], link_with: libstatic)
        install_data(meson.current_build_dir() / 'ymp-cli-static', install_dir : get_option('bindir'),rename : 'ymp-static')
    endif
    if get_option('test')
        executable('ymp-test', 'test/test.vala', dependencies: static_dependencies, link_args: args + ['-static'], link_with: libstatic)
    endif

endif

if get_option('scripts')
    foreach script : run_command('find', 'scripts','-type','f',check:true).stdout().strip().split('\n')
        install_data(script, install_dir : get_option('bindir'))
    endforeach
endif

install_data('data/ymp.yaml', install_dir : get_option('sysconfdir'), rename : 'ymp.yaml')
install_data('data/application-x-ymp.svg', install_dir : get_option('prefix') / 'share/icons/hicolor/scalable/mimetypes/')
install_data('data/ymp-mime.xml', install_dir : get_option('prefix') / 'share/mime/packages/')

install_data(meson.current_build_dir() / 'obj.o', install_dir : get_option('libdir'), rename : 'empty.o')
install_data(meson.current_build_dir() / 'ymp.h', install_dir : get_option('includedir'), rename : 'ymp.h')
install_data(meson.current_build_dir() / 'ymp.vapi', install_dir : get_option('prefix')/'share/vala/vapi/', rename : 'libymp-'+meson.project_version()+'.vapi')

