logger log;
int main () {
    log = new logger();
    var tar = new archive();
    tar.load("main.tar");
    tar.extract_all();
    return 0;
}
