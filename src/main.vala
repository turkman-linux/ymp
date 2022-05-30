int main (string[] args) {
    Inary inary = inary_init(args);
    inary.add_process(args[1],args[2:]);
    inary.run();
    error(1);
    return 0;
}
