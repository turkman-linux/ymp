int main(string[] args){
    set_value2("amogus","31");
    set_value2("amogus31","32");
    set_value2("amogus","32");
    stdout.printf("%s\n", get_value2("amogus"));
    foreach(string a in get_value_names2()){
        stdout.printf("%s\n", a);
    }
    return 0;
}
