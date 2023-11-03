project(
    'ymp',
    'vala', 'c',
    meson_version: '>= 0.54.0',
    version : '1.0',
    license: ['GplV3']
)
if meson.get_compiler('vala').version().version_compare('<0.54.9')
    error('vala compiler version 0.54.9 or newer is required.')
endif

conf = []
compiler = meson.get_compiler('c')
message('\x1b[32;1mGenerate:\x1b[;0m','ctx.vala')
run_command('bash', './tool/mkctx.sh',
    'CONFIGDIR=/'+get_option('sysconfdir'),
    'STORAGEDIR=/'+get_option('storagedir'),
    'DISTRODIR=/'+get_option('distrodir'),
    'VERSION='+meson.project_version(),
    check:true)

run_command('bash', './tool/check.sh', meson.current_build_dir(), check:true)
prep_args = ['-L'+meson.current_build_dir(), '-lymp']
args = prep_args
libc_srcs = []

# disable optimization for test
if not get_option('test')
    args += ['-O3', '-flto', '-Wall','-lm',
            '-fvisibility=hidden', '-Wextra', '-Wno-unused-parameter','-s', '-Os',
            '-Wl,--gc-sections','-ffunction-sections', '-fno-math-errno', '-ffast-math',
            '-fdata-sections', '-fno-exceptions', '-fno-unwind-tables', '-fpack-struct',
            '-fno-asynchronous-unwind-tables', '-fno-math-errno', '-fcf-protection',
            '-fno-unroll-loops', '-fmerge-all-constants', '-fno-ident', '-ffast-math',
            '-fsingle-precision-constant', '-Wl,--build-id=none', '-Wl,-z,norelro',
            '-Wl,--hash-style=sysv', '-fpie', '-fpic', '-Wl,-v', '-Wl,-z,now',
            '-Wno-ignored-optimization-argument', '-pipe', '-D_FORTIFY_SOURCE=2',
            '-Wl,--as-needed', '-Wl,--strip-all', '-Wl,-z,max-page-size=0x1000',
            '-fshort-enums', '-fwhole-program', '-ffreestanding'
    ]
    if compiler.get_id() == 'clang'
        args += ['-gembed-source', '-gdwarf-5']
    endif

endif

# do not include glibc or musl stdlib and link with glibc or musl
if run_command('/bin/sh', '-c', 'ldd --version | grep musl').returncode() == 0
    args += ['-nostdlib', '-lc.musl']
else
    args += ['-nostdlib', '-lc']
endif


args += [meson.current_build_dir()/ 'obj.o']
deps = []

pkgconfig_arg = ''

if get_option('static')
    pkgconfig_arg = '--static'
    args += ['--static']
    conf += ['STATIC']
else
    conf += ['SHARED']
endif

# valac configuration
add_project_arguments('-C', language: 'vala')
add_project_arguments(['--disable-assert', '--hide-internal', '--nostdpkg', '--enable-checking', '--abi-stability'], language: 'vala')
add_project_arguments('-D', '_GNU_SOURCE', '--disable-version-header', language: 'vala')
add_project_arguments(['--pkg', 'posix'], language: 'vala')


# gio
deps += [dependency('gio-2.0', static: get_option('static'), required:true)]

# glib-2.0
args += run_command(
        'pkg-config', '--libs', 'glib-2.0', pkgconfig_arg ,check:true
        ).stdout().strip().split(' ')

#libarchive
if get_option('libarchive')
        libarchive = dependency('libarchive', static:get_option('static'),required:false)
        if not libarchive.found()
            conf += ['no_libarchive']
        endif
        deps += [libarchive]
endif

#libarchive
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
            args += run_command('pkg-config', '--libs', '--cflags' ,'libcurl', pkgconfig_arg ,check:true).stdout().strip().split(' ')
            if get_option('libbrotli')
                args += ['-lbrotlicommon']
            endif
        endif
#libsoup-3.0 (no vapi)
elif get_option('libsoup')
        libsoup = dependency('libsoup-3.0', static:get_option('static'), required:false)
        if not libsoup.found()
        else
            conf += ['libsoup']
            args += run_command('pkg-config', '--libs', '--cflags', 'libsoup-3.0', pkgconfig_arg ,check:true).stdout().strip().split(' ')
        endif
else
    conf += ['no_fetcher_backend']
endif

#libmagic (no vapi)
if get_option('libmagic')
        libmagic = dependency('libmagic', static:get_option('static'),required:false)
        if not libmagic.found()
            conf += ['no_libmagic']
        else
            args += run_command('pkg-config', '--libs', '--cflags' ,'libmagic', pkgconfig_arg ,check:true).stdout().strip().split(' ')
        endif
endif

# find sources
sources = ['src/ymp.vala',
           'src/settings.vala',
           'src/wslblock.vala',
           'src/ccode.vala',
           'data/ymp-extra.h'
          ]

sources += run_command('find', 'src/util','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/operations','-type','f',check:true).stdout().strip().split('\n')
sources += run_command('find', 'src/data','-type','f',check:true).stdout().strip().split('\n')


foreach csource : run_command('find', 'src/ccode','-type','f',check:true).stdout().strip().split('\n')
    args += [meson.current_source_dir() / csource]
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
    args += ['-g3', '-grecord-gcc-switches', '-DDEBUG']
    conf += ['DEBUG']
else
    args += ['-DNDEBUG']
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


########### build ymp.pc ###########

run_command('install', 'data/ymp.pc', meson.current_build_dir(), check: true)
run_command('sed', '-i', 's/@version@/'+meson.project_version()+'/g', meson.current_build_dir()+'/ymp.pc', check: true)

foreach c : conf
    add_project_arguments('-D', c, language: 'vala')
    prep_args += '-D'+c
    args += '-D'+c
endforeach

########### generate vala sources ###########

generated_sources=[]
foreach valasrc : sources
    message('\x1b[32;1mGenerate:\x1b[;0m' ,valasrc)
    run_command('bash', 'tool/preprocessor.sh','.generated',valasrc, prep_args,check:true)
    generated_sources += '.generated'/valasrc
endforeach


if get_option('nolibc_path') != ''
    args += ['-nostdlib', '-I'+get_option('nolibc_path')]
endif


generated_sources += ['ctx.vala']
########### build libymp ###########
if get_option('static')
    libymp = static_library('ymp', generated_sources, dependencies: deps, link_args: args)
else
    libymp = library('ymp', generated_sources, dependencies: deps, link_args: args)
endif
install_data(meson.current_build_dir() / 'libymp.so', install_dir : get_option('libdir'), rename: 'libymp.so')

########### build tools ###########
if get_option('tools')
    # ymp cli
    executable('ymp-cli', 'src/cli/main.c',libc_srcs, dependencies: deps, link_args: prep_args, link_with: libymp)
    install_data(meson.current_build_dir() / 'ymp-cli', install_dir : get_option('bindir'),rename : 'ymp')
    # ymp shell
    executable('ymp-shell', 'src/cli/shell.c', libc_srcs, dependencies: deps, link_args: prep_args, link_with: libymp)
    install_data(meson.current_build_dir() / 'ymp-shell', install_dir : get_option('bindir'),rename : 'ympsh')
endif
########### build test ###########
if get_option('test')
    executable('ymp-test', 'test/test.vala', dependencies: deps, link_args: prep_args, link_with: libymp)
endif

########### build scripts ###########
if get_option('scripts')
    foreach script : run_command('find', 'scripts','-type','f',check:true).stdout().strip().split('\n')
        install_data(script, install_dir : get_option('bindir'))
    endforeach
endif

########### install files ###########
install_data('data/ymp.yaml', install_dir : get_option('sysconfdir'))
install_data(meson.current_build_dir()+'/ymp.pc', install_dir : get_option('libdir')/ 'pkgconfig')
install_data('data/application-x-ymp.svg', install_dir : get_option('prefix') / 'share/icons/hicolor/scalable/mimetypes/')
install_data('data/fix-turkish.sed', install_dir : get_option('prefix') / 'share/ymp/')
install_data('data/ymp-mime.xml', install_dir : get_option('prefix') / 'share/mime/packages/')
install_data('data/ymp-extra.h', install_dir : get_option('includedir'))
install_data('data/debian-names.yaml', install_dir : get_option('sysconfdir'))

install_data(meson.current_build_dir() / 'obj.o', install_dir : get_option('libdir'), rename : 'empty.o')
install_data(meson.current_build_dir() / 'ymp.h', install_dir : get_option('includedir'))
install_data(meson.current_build_dir() / 'ymp.vapi', install_dir : get_option('prefix')/'share/vala/vapi/')
