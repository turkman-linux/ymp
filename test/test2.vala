int main(string[] args){
    array2 a = new array2();
    a.add("Hello");
    a.add("world");
    for(int i = 0; i<a.length();i++){
        stdout.printf("%s\n", a.get(i));
    }
    return 0;
}