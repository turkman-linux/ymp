int main(string[] args){
    sandbox_network = true;
    int status = sandbox(args[1:]);
    return status/256;
}
