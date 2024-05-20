public class test {
    public test(){}
    public void p(string message){
        stdout.printf(message);
    }

}

public void test2(string message){
    stdout.printf(message);
}

int main(string[] args){
    jobs j = new jobs();
    test t = new test();
    t.p("Hello World\n");
    j.add((void*)t.p, t, "Hello World\n");
    j.add((void*)test2, "Hello World\n");
    j.run();
    ymp_init(args);
    return 0;
}