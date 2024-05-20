public struct job {
    public unowned void* callback;
    public unowned void* args;
    public int id;
}

[CCode (cheader_filename = "jobs.h")]
public class jobs {
    public job* jobs;
    public jobs();
    public int max;
    public int current;
    public int parallel;
    public int finished;
    public int total;

    public void unref ();
    public void add (void* callback, void* args, ...);
    public void run ();
}
