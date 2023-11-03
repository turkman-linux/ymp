public void build_target_deb_init() {
    build_target deb_target = new build_target();
    deb_target.suffix = "deb";
    deb_target.name = "deb";
    deb_target.create_source_archive.connect(() => {
        return "ignore";
    });

    deb_target.create_files_info.connect(() => {
        return true;
    });

    deb_target.create_metadata_info.connect(() => {
        string buildpath = srealpath(deb_target.builder.ymp_build.ympbuild_buildpath);
        create_dir(buildpath + "/output/DEBIAN/");
        string control = "";
        string metadata = deb_target.builder.ymp_build.get_ympbuild_metadata();
        var yaml = new yamlfile();
        yaml.data = metadata;
        string srcdata = yaml.get("ymp.source");
        string name = yaml.get_value(srcdata, "name");
        string version = yaml.get_value(srcdata, "version");
        control += "Package: %s\n".printf(name);
        control += "Version: %s\n".printf(version);
        // FIXME: replace with right architecture
        control += "Architecture: all\n";
        control += "Installed-Size: 1\n";
        control += "Depends: %s\n".printf(join(", ", yaml.get_array(srcdata, "depends")));
        control += "Description: Created by YMP\n";
        control += " %s".printf(yaml.get_value(srcdata, "description"));
        writefile(buildpath + "/output/DEBIAN/control", control);
        deb_target.builder.output_package_name = name + "_" + version;
        return true;
    });

    deb_target.create_data_file.connect(() => {
        return;
    });

    deb_target.create_binary_package.connect(() => {
        string buildpath = srealpath(deb_target.builder.ymp_build.ympbuild_buildpath);
        deb_create(buildpath+"/output", buildpath+"/package.deb");
        return buildpath+"/package.deb";
    });
    add_build_target(deb_target);
}
