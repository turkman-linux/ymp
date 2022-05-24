project('inary', 'vala', 'c')

dependencies = [
    dependency('libarchive'),
    dependency('gio-2.0'),
]

sources = files('src/util/archive.vala'
               )

lib = library('inary', sources, dependencies: dependencies)

executable('inary', 'src/main.vala', dependencies: dependencies, link_with: lib)
