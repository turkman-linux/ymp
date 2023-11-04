public void build_target_dummy_init() {
    build_target dummy_target = new build_target();
    dummy_target.suffix = "dummy";
    dummy_target.name = "dummy";
    dummy_target.arch = "none";
    dummy_target.create_source_archive.connect(() => {
        writefile("/tmp/dummy-src", "");
        return "/tmp/dummy-src";
    });

    dummy_target.create_files_info.connect(() => {
        return true;
    });

    dummy_target.create_metadata_info.connect(() => {
        return true;
    });

    dummy_target.create_data_file.connect(() => {
        return;
    });

    dummy_target.create_binary_package.connect(() => {
        writefile("/tmp/dummy-pkg", "");
        return "/tmp/dummy-pkg";
    });
    add_build_target(dummy_target);
}
