module lib.fasta_handler;

import std.stdio;
import std.string;

import lib.de_breijn_graph;

public class FastaHandler {
    public const string pathToFasta;
    private DBGraph graph;

    public this(DBGraph graph, string pathToFasta) {
        this.graph = graph;
        this.pathToFasta = pathToFasta;
    }

    public void readData() {
        File file = File(pathToFasta, "r");
        while (!file.eof()) {
            string line = strip(file.readln());
            if (!line.startsWith(">")) {
                graph.addRead(line);
            }
        }
        file.close();
    }
}
