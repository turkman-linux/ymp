//DOC: ## Dependency analysis
//DOC: resolve dependencies;
private string[] need_install;
private string[] cache_list;

private void resolve_process(string[] names){
    foreach(string name in names){
        // 1. block process packages for multiple times.
        if(name in cache_list){
            return;
        }else{
            cache_list += name;
        }
        // 2. process if not installed or need install
        if (!(name in need_install || is_installed_package(name))){
            // get package object from repository
            package pkg = get_package_from_repository(name);
            // run recursive function
            resolve_process(pkg.dependencies);
            // add package to list
            debug(name);
            need_install += name;
        }
    }
    return;
}
//DOC: `string[] resolve_dependencies(string[] names):`;
//DOC: return package name list with required dependencies;
public string[] resolve_dependencies(string[] names){
    // reset need list
    need_install = {};
    // reset cache list
    cache_list = {};
    // process
    resolve_process(names);
    error(3);
    return need_install;
}
