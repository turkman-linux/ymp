int main (string[] args) {
    Ymp ymp = ymp_init (args);
    ymp.add_process ("shell", args[1:]);
    ymp.run ();
    error (1);
    return 0;
}
