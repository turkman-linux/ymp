int main(string[] args){
    array2 a = new array2();
    a.add("Hello");
    a.add("World");
    a.remove("Hello");
    a.add("Hi");
    a.reverse();
    a.sort();
    foreach(string d in a.get()){
        stdout.printf("%s %d\n",d, a.length());
    }
    return 0;
}
