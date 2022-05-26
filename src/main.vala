int main (string[] args) {
    Inary inary = inary_init();
    inary.add_process(args[1],args[2:]);
    inary.run();
    return 0;
}
