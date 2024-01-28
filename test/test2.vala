int main(string[] args){
    array2 a = new array2();
    a.add("Hello");
    a.add("World");
    a.remove("Hello");
    a.add("Hi");
    a.insert("amogus",0);
    a.add("Hi");
    a.add("Hi");
    //a.reverse();
    //a.uniq();
    //a.sort();
    foreach(string d in a.get()){
        stdout.printf("%s %d\n",d, a.length());
    }
    return 0;
}
