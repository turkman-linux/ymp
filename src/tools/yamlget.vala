int main(string[] args){
    if (args.length < 3){
        print_stderr("Usage: iniget [file] [path]");
        return 1;
    }
    var file = args[1];
    var path = args[2];
    var yaml = new yamlfile();
    yaml.load(file);
    print(yaml.get(path));
    return 0;
}
