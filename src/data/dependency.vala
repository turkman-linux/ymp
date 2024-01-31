//DOC: ## Dependency analysis
//DOC: resolve dependencies
private array need_install;
private array cache_list;

private bool ignore_missing;
private bool reinstall;
private bool ignore_dependency;
private int max_depth = -1;
private bool unsafe;

private int depth=0;

private static void resolve_process (string[] names) {
    foreach (string name in names) {
        info (_ ("Resolve dependency: %s %d").printf (name, depth));
        // 1. block process packages for multiple times.
        if (cache_list.has (name)) {
            continue;
        }else {
            cache_list.add (name);
        }
        if (name[0] == '@') {
            string[] grp = get_group_packages (name);
            resolve_process (grp);
            continue;
        }
        if (name[0] == '!') {
            string[] matches = get_match_packages (name);
            resolve_process (matches);
            continue;
        }
        if ("|" in name) {
            name = get_ordep_package (name);
        }
        if(max_depth < depth){
            continue;
        }
        // 2. process if not installed or need install
        if (!need_install.has (name)) {
            // get package object
            package pkg = null;
            if (startswith (name, "http://") || startswith (name, "https://")) {
                fetch (name, get_storage () + "/packages/" + sbasename (name));
                name = get_storage () + "/packages/" + sbasename (name);
            }
            if (isfile (name)) {
                pkg = get_package_from_file (name);
            }else if (is_available_from_repository (name)) {
                pkg = get_from_repository (name);
                if (!reinstall && is_installed_package (name)) {
                    if (pkg.release <= get_installed_package (name).release) {
                        continue;
                    }
                }
            }else if (is_installed_package (name)) {
                if (!reinstall) {
                    continue;
                }else {
                    pkg = get_installed_package (name);
                }
            }else {
                string errmsg = _ ("Package is not installable: %s").printf (name);
                if (!ignore_missing) {
                    error_add (errmsg);
                } else {
                    warning (errmsg);
                    continue;
                }
            }
            if (pkg == null) {
                continue;
            }
            if (!unsafe && pkg.is_unsafe()) {
                error_add("Unsafe package detected! If you want to install please use --unsafe.");
            }
            if (!ignore_dependency) {
                // run recursive function
                depth += 1;
                resolve_process (pkg.dependencies);
                depth -= 1;
            }
            // add package to list
            debug (name);
            need_install.add (name);
        }
    }
}

private static string[] get_group_packages (string fname) {
    info (_ ("Resolve group: %s").printf (fname));
    array ret = new array ();
    string[] pkgnames = list_available_packages ();
    string name = fname[1:];
    if (name == "universe") {
        return pkgnames;
    }else if (name == "world") {
        return list_installed_packages ();
    }
    foreach (string pkgname in pkgnames) {
        package p = get_from_repository (pkgname);
        if (p == null) {
            continue;
        }
        foreach (string grp in p.gets ("group")) {
            if (name == grp || startswith (grp, name + ".")) {
                debug (_ ("Group %s: add: %s").printf (grp, pkgname));
                ret.add (pkgname);
            }
        }
    }
    if (ret.length () == 0) {
        error_add (_ ("Group is unknown: %s").printf (fname));
    }
    return ret.get ();
}

private static string get_ordep_package (string fname) {
    info (_ ("Resolve ordep packages: %s").printf (fname));
    foreach (string pkgname in ssplit (fname, "|")) {
        if (is_installed_package (pkgname)) {
            return pkgname;
        }
    }
    foreach (string pkgname in ssplit (fname, "|")) {
        package p = get_from_repository (pkgname);
        if (p != null) {
            return pkgname;
        }
    }
    return ssplit (fname, "|")[0];
}

private static string[] get_match_packages (string fname) {
    info (_ ("Resolve regex: %s").printf (fname));
    array ret = new array ();
    string rule = fname[1:];
    string[] pkgnames = list_available_packages ();
    foreach (string pkgname in pkgnames) {
        package p = get_from_repository (pkgname);
        if (p == null) {
            continue;
        }
        if (Regex.match_simple (rule, pkgname)) {
            info (_ ("Match %s: rule: %s").printf (pkgname, rule));
            ret.add (pkgname);
        }
    }
    if (ret.length () == 0) {
        error_add (_ ("Regex match is not available: %s").printf (fname));
    }
    return ret.get ();
}

public string[] get_upgradable_packages () {
    string[] need_upgrade = {};
    foreach (string name in list_installed_packages ()) {
        if (!is_available_package (name)) {
            continue;
        }
        package pi = get_installed_package (name);
        package pr = get_package_from_repository (name);
        if (pi.release < pr.release) {
            need_upgrade += name;
        }
    }
    return need_upgrade;
}

private string[] get_unsafe_packages () {
    string[] unsafe_list = {};
    foreach (string name in list_installed_packages ()) {
        package pi = get_installed_package (name);
        if(pi.is_unsafe()){
            unsafe_list += name;
        }
    }
    return unsafe_list;
}

private static void resolve_reverse_process (string[] names) {
    string[] pkgnames = list_installed_packages ();
    foreach (string name in names) {
        if (cache_list.has (name)) {
            continue;
        }else {
            cache_list.add (name);
        }
        if (name[0] == '@') {
            string[] grp = get_group_packages (name);
            resolve_reverse_process (grp);
            continue;
        }
        if (name[0] == '!') {
            string[] matches = get_match_packages (name);
            resolve_reverse_process (matches);
            continue;
        }
        if(max_depth < depth){
            continue;
        }
        info (_ ("Resolve reverse dependency: %s %d").printf (name, depth));
        if (is_installed_package (name)) {
            need_install.add (name);
        }else {
            continue;
        }
        if (ignore_dependency) {
            continue;
        }
        foreach (string pkgname in pkgnames) {
            package pkg = get_installed_package (pkgname);
            if (name in pkg.dependencies) {
                string[] tmp = {pkgname};
                depth += 1;
                resolve_reverse_process (tmp);
                depth -= 1;
            }
        }
    }
}

//DOC: `string[] resolve_dependencies (string[] names):`
//DOC: return package name list with required dependencies
public string[] resolve_dependencies (string[] names) {
    // set variables
    ignore_dependency = get_bool("ignore-dependency");
    ignore_missing = get_bool("ignore-missing");
    reinstall = get_bool("reinstall");
    unsafe = get_bool ("unsafe");
    max_depth = int.parse(get_value("max-depth"));
    if (max_depth <= 0) {
        max_depth = 1000000;
    }
    
    // reset need list
    need_install = new array ();
    // reset cache list
    cache_list = new array ();
    depth=0;
    resolve_process (names);
    error (3);
    return need_install.get ();
}

//DOC: `string[] resolve_reverse_dependencies (string[] names):`
//DOC: return package name list with required reverse dependencies
public string[] resolve_reverse_dependencies (string[] names) {
    ignore_dependency = get_bool("ignore-dependency");
    ignore_missing = get_bool("ignore-missing");
    reinstall = get_bool("reinstall");
    unsafe = get_bool ("unsafe");
    max_depth = int.parse(get_value("max-depth"));
    if (max_depth <= 0) {
        max_depth = 1000000;
    }
    // reset need list
    need_install = new array ();
    // reset cache list
    cache_list = new array ();
    depth=0;
    resolve_reverse_process (names);
    error (3);
    return need_install.get ();
}
