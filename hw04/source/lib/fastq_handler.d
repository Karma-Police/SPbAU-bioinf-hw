module lib.fastq_handler;

import std.stdio;
import std.string;

import lib.de_breijn_graph;

public class FastqHandler {
    public const string pathToFastq;
    private DBGraph graph;

    public this(DBGraph graph, string pathToFastq) {
        this.graph = graph;
        this.pathToFastq = pathToFastq;
    }

    public void readData() {
        File file = File(pathToFastq, "r");
        while (!file.eof()) {
            string line = strip(file.readln());
            if (line.startsWith("@")) {
                line = strip(file.readln());
                graph.addRead(line);
                file.readln(); // +
                file.readln(); // probability
            }
        }
        file.close();
    }
}
