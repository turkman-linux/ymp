int main(string[] args){
    array2 a = new array2();
    a.add("Hello");
    a.add("World");
    a.remove("Hello");
    a.add("Hi");
    a.insert("amogus",0);
    a.add("Hi");
    a.add("Hi");
    string[] aaa = {"Ekmegi","elden", "y**ragi", "kelden"};
    a.adds(aaa);
    //a.reverse();
    //a.uniq();
    //a.sort();
    foreach(string d in a.get()){
        stdout.printf("%s %d\n",d, a.length());
    }
    stdout.printf(a.get_string());
    return 0;
}
