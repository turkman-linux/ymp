project(
    'ymp',
    'vala', 'c',
    meson_version: '>= 0.58.0',
    version : '1.1',
    license: ['GplV3']
)
if meson.get_compiler('vala').version().version_compare('<0.54.9')
    error('vala compiler version 0.54.9 or newer is required.')
endif

conf = []
compiler = meson.get_compiler('c')
architecture = run_command('uname', '-m', check:true).stdout().strip()

message('\x1b[32;1mGenerate:\x1b[;0m','ctx.vala')
run_command('bash', './tool/mkctx.sh',
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    'DISTRODIR=/'+get_option('distrodir'),
    'VERSION='+meson.project_version(),
    check:true)

run_command('bash', './tool/check.sh', meson.current_build_dir(), check:true)
cflags = ['-I'+meson.current_source_dir()/'src/include/']
ldflags = ['-L'+meson.current_build_dir(), '-lymp']
if get_option('ansi')
    cflags += ['-ansi']
endif

# disable vala related warnings
cflags += ['-Wno-unused', '-Wno-unused-result', '-Wno-incompatible-pointer-types',
         '-Wno-discarded-qualifiers', '-Wno-infinite-recursion',
         '-Wno-cast-function-type', '-Wno-attributes','-Wno-unknown-warning-option',
        ]

cflags += ['-DGETTEXT_PACKAGE=ymp']

# some compiler flags from dpkg-buildpackage
cflags += ['-g', '-O2', '-Werror=implicit-function-declaration',
         '-ffile-prefix-map=/root/ymp=.', '-fstack-protector-strong',
         '-fstack-clash-protection', '-Wformat', '-Werror=format-security'
        ]

# error on warning
if compiler.get_id() == 'gcc'
    cflags += ['-Werror']
endif

libc_srcs = []

start_code = []

# do not include glibc or musl stdlib and link with glibc or musl
if run_command('/bin/sh', '-c', 'ldd /proc/self/exe | grep /lib/ld-musl-'+architecture+'.so.1').returncode() == 0
    cflags += ['-Dmusl']
else
    if not get_option('test')
        ldflags += ['-nostdlib', '-lc']
        start_code += ['src/start/'+architecture+'.s' ]
    endif
endif


deps = []

pkgconfig_dep = []
pkgconfig_arg = ''

if get_option('static')
    pkgconfig_arg = '--static'
    ldflags += ['--static']
    conf += ['STATIC']
else
    conf += ['SHARED']
endif

# valac configuration
add_project_arguments(['--disable-assert', '--hide-internal', '--nostdpkg', '--enable-checking', '--abi-stability'], language: 'vala')
add_project_arguments('-D', '_GNU_SOURCE', '--disable-version-header', language: 'vala')
add_project_arguments(['--pkg', 'posix'], language: 'vala')

# vapi directory (valac configunation)
add_project_arguments('--vapidir', meson.current_source_dir() / 'src/vapi/', language: 'vala')

foreach vapi : run_command('find', 'src/vapi','-type','f',check:true).stdout().strip().split('\n')
    vapi = vapi.replace('.vapi','')
    vapi = vapi.split('/')[-1]
    add_project_arguments('--pkg', vapi, language: 'vala')
endforeach


# gio
deps += [dependency('gio-2.0', static: get_option('static'), required:true)]

# glib-2.0
pkgconfig_dep += ['gio-2.0']


#libarchive
if get_option('libarchive')
        libarchive = dependency('libarchive', static:get_option('static'),required:false)
        if not libarchive.found()
            conf += ['no_libarchive']
        endif
        deps += [libarchive]
else
    conf += ['no_libarchive']
endif

#libreadline
if get_option('libreadline')
        libreadline = dependency('readline', static:get_option('static'), required:false)
        if not libreadline.found()
            conf += ['no_libreadline']
        endif
        deps += [libreadline]
endif

#libcurl (no vapi)
if get_option('libcurl')
        libcurl = dependency('libcurl', static:get_option('static'), required:false)
        if not libcurl.found()
        else
            conf += ['libcurl']
            pkgconfig_dep += ['libcurl']
            if get_option('libbrotli')
                ldflags += ['-lbrotlicommon']
            endif
        endif
#libsoup-3.0 (no vapi)
elif get_option('libsoup')
        libsoup = dependency('libsoup-3.0', static:get_option('static'), required:false)
        if not libsoup.found()
        else
            conf += ['libsoup']
            pkgconfig_dep += ['libsoup-3.0']
       endif
else
    conf += ['no_fetcher_backend']
endif

# find sources
sources = ['src/ymp.vala',
           'src/settings.vala',
           'src/operations.vala',
           'src/process.vala',
           'src/interpreter.vala',
           'src/wslblock.vala',
           'src/ccode.vala',
           'data/ymp-extra.h'
          ]
sources += run_command('find', 'src/util','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/operations','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/data','-type','f',check:true).stdout().strip().split('\n')


foreach csource : run_command('find', 'src/ccode','-type','f',check:true).stdout().strip().split('\n')
    sources += [meson.current_source_dir() / csource]
endforeach


# locale settings
if get_option('locale')
    subdir('po')
else
    conf += ['no_locale']
endif

# experimental features
if get_option('experimental')
    conf += ['experimental']
endif


# debug
if get_option('debug')
    add_project_arguments('--debug', language: 'vala')
    cflags += ['-g3', '-Wall', '-Wextra', '-grecord-gcc-switches','-fdiagnostics-color=always', '-DDEBUG']
    conf += ['DEBUG']
else
    cflags += ['-DNDEBUG']
    conf += ['NDEBUG']
endif

# colorize options
if not get_option('colorize')
    conf += ['NOCOLOR']
endif

# oem check feature
if get_option('check_oem')
    conf += ['check_oem']
endif

########### add ldflags and cflags ###########
foreach name: pkgconfig_dep
    # Run the pkg-config command and capture its output
    ldflags += run_command(
        'pkg-config', '--libs', name, pkgconfig_arg, check: true
    ).stdout().strip().split(' ')
    # Run the pkg-config command and capture its output
    cflags += run_command(
        'pkg-config', '--cflags', name, pkgconfig_arg, check: true
    ).stdout().strip().split(' ')
endforeach

########### build ymp.pc ###########

run_command('install', 'data/ymp.pc', meson.current_build_dir(), check: true)
run_command('sed', '-i', 's/@version@/'+meson.project_version()+'/g', meson.current_build_dir()+'/ymp.pc', check: true)

foreach c : conf
    add_project_arguments('-D', c, language: 'vala')
    cflags += '-D'+c
endforeach

########### generate vala sources ###########

generated_sources=[]
foreach valasrc : sources
    message('\x1b[32;1mGenerate:\x1b[;0m' ,valasrc)
    run_command('bash', 'tool/preprocessor.sh','.generated',valasrc, cflags,check:true)
    generated_sources += '.generated'/valasrc
endforeach


if get_option('nolibc_path') != ''
    cflags += ['-nostdlib', '-I'+get_option('nolibc_path')]
endif

add_project_arguments('-I'+meson.current_source_dir()+'/src/include/', language : 'c')
add_project_arguments('-fPIC', language : 'c')
generated_sources += ['ctx.vala']

foreach arg : cflags
    if arg != ''
        add_project_arguments(arg, language : 'c')
    endif
endforeach

########### build libymp ###########
if get_option('static')
    libymp = static_library('ymp', generated_sources, dependencies: deps, link_args: ldflags)
else
    libymp = shared_library('ymp', generated_sources, dependencies: deps, link_args: ldflags)
endif


install_data(meson.current_build_dir() / 'libymp.so', install_dir : get_option('libdir'), rename: 'libymp.so')


########### build tools ###########
if get_option('tools')
    # ymp cli
    cli = executable('ymp-cli', ['src/cli/main.c'] + start_code, libc_srcs, dependencies: deps, link_args: ldflags , link_with: libymp)
    install_data(meson.current_build_dir() / 'ymp-cli', install_dir : get_option('bindir'),rename : 'ymp')

    # ymp shell
    shell = executable('ymp-shell', ['src/cli/shell.c'] + start_code, libc_srcs, dependencies: deps, link_args: ldflags, link_with: libymp)
    install_data(meson.current_build_dir() / 'ymp-shell', install_dir : get_option('bindir'),rename : 'ympsh')

endif

########### build start code ###########
start_name = 'start-' +architecture + '.o'
run_command(compiler.get_id(), '-c', 'src/start/'+architecture+'.s', 
   '-nostdlib', '-static', '-o', meson.current_build_dir() / start_name ,
    check:true)
    install_data(meson.current_build_dir() / start_name, install_dir : get_option('libdir'),rename : start_name)

########### build test ###########
if get_option('test')
    executable('ymp-test', ['test/test.vala'] + start_code, dependencies: deps, link_args: ldflags, link_with: libymp)
endif

########### build scripts ###########
if get_option('scripts')
    foreach script : run_command('find', 'scripts','-type','f',check:true).stdout().strip().split('\n')
        install_data(script, install_dir : get_option('bindir'))
    endforeach
endif

########### code runner plugins ###########

foreach plugin : run_command('find', 'data/code-runner-plugins','-type','f',check:true).stdout().strip().split('\n')
    install_data(plugin, install_dir : '/lib/code-runner/')
endforeach

########### install files ###########
install_data('data/ymp.yaml', install_dir : get_option('sysconfdir'))
install_data('data/org.turkman.ymp.extract.desktop', install_dir : get_option('prefix') / 'share/applications')
install_data(meson.current_build_dir()+'/ymp.pc', install_dir : get_option('libdir')/ 'pkgconfig')
install_data('data/application-x-ymp.svg', install_dir : get_option('prefix') / 'share/icons/hicolor/scalable/mimetypes/')
install_data('data/fix-turkish.sed', install_dir : get_option('prefix') / 'share/ymp/')
install_data('data/ymp-mime.xml', install_dir : get_option('prefix') / 'share/mime/packages/')
install_data('data/debian-names.yaml', install_dir : get_option('sysconfdir'))
install_data(meson.current_build_dir() / 'obj.o', install_dir : get_option('libdir'), rename : 'empty.o')

########### install headers ###########
install_data(meson.current_build_dir() / 'ymp.h', install_dir : get_option('includedir')/'ymp/')
install_data(meson.current_source_dir() / 'data/ymp-extra.h', install_dir : get_option('includedir')/'ymp/', rename : 'extra.h')
foreach header : run_command('find', 'src/include','-type','f',check:true).stdout().strip().split('\n')
    install_data(meson.current_source_dir() / header, install_dir : get_option('includedir')/'ymp/')
endforeach
install_data(meson.current_build_dir() / 'ymp.vapi', install_dir : get_option('prefix')/'share/vala/vapi/')
