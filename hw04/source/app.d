import std.stdio;
import std.conv;
import std.string;

import lib.de_breijn_graph;
import lib.fasta_handler;
import lib.fastq_handler;

void printUsage() {
    stdout.writeln("Usage: DeBruijnGraph [k-mer size] [path to fasta/fastq file] [OPT path to result .gv gile]");
}

void main(string[] args)
{
    if (args.length < 3 || args.length > 4) {
        printUsage();
        return;
    }
    int k = to!int(args[1]);
    string pathToDotFile = "result.gv";
    if (k <= 0 || k % 2) {
        printUsage();
        stdout.writeln("Expected positive even k-mer size.");
        return;
    }
    if (args.length > 3) {
        pathToDotFile = args[3];
    }
    
    DBGraph graph = new DBGraph(k);

    if (args[2].endsWith(".fasta")) {
        new FastaHandler(graph, args[2]).readData();
    } else if (args[2].endsWith(".fastq")){
        new FastqHandler(graph, args[2]).readData();
    } else {
        printUsage();
        stdout.writeln("Expected fasta/fastq file");
    }
//    graph.printNodes();
//    stdout.writeln(graph.size());
    graph.compress();
    graph.saveToGvFile(pathToDotFile);
//    stdout.writeln(graph.size());
//    graph.printNodes();
}
