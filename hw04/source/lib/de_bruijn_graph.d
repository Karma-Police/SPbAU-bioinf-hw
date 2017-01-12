module lib.de_breijn_graph;

import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import std.algorithm.mutation;


public class DBGraph {
    alias ParNode = Tuple!(Node, "node", char, "nuc");

    public const uint ksize;

    private Node[] nodes;
    private ulong[string] nodepos; 
    private bool notCompressed;

    public this(uint ksize) {
        assert(!(ksize % 2));
        this.ksize = ksize;
        this.notCompressed = true;
    }

    public ulong size() const {
        return nodes.length;
    }

    public void addRead(string read) {
        assert(notCompressed);
        string compRead = getComp(read);
        addReadToGraph(read);
        addReadToGraph(compRead);
    }

    public void printNodes() const {
        foreach (node; nodes) {
            stderr.writeln(node.kmer);
        }
    }

    public void saveToGvFile(string path) const {
        File file = File(path, "w");
        file.writeln("digraph mygraph {");
        for (int i = 0; i < nodes.length; i++) {
            auto curNode = nodes[i];
            for (int c = 0; c < 4; c++) {
                if (curNode.edge[c].length) {
                    string line = "\t" ~ to!string(i) ~ " -> ";
                    ulong nxtNode = nodepos[(curNode.kmer ~ curNode.edge[c])[$ - ksize .. $]];
                    line ~= to!string(nxtNode) ~ " [label=\"" ~ to!string(curNode.coverCnt[c] * 1.0 / curNode.edge[c].length) ~ "\"];";
                    file.writeln(line);
                }
            }
        }
        file.writeln("}");
        file.close();
    }

    public void compress() {
        ulong[string] used;
        int curtime = 1;
        notCompressed = false;
        for (int i = 0; i < nodes.length; i++) {
            ++curtime;
            Node cur = nodes[i];
            Node nxt = null;
            int nxtcnt = 0;
            ulong nxtPos = 0;
            char[] edge;
            uint edgecnt;
            for (int c = 0; c < 4; c++) {
                if (cur.edge[c].length) {
                    assert(cur.kmer.length == ksize);
                    string nxtkmer = cast(string)((cur.kmer ~ cur.edge[c])[$-ksize..$]);
                    assert(nxtkmer in nodepos);
                    nxtPos = nodepos[nxtkmer];
                    nxt = nodes[nxtPos];
                    edge = cur.edge[c];
                    edgecnt = cur.coverCnt[c];
                    nxtcnt += 1;
                }
            }
            if (cur.parNodes.length && nxtcnt == 1) {
                foreach (parNode; cur.parNodes) {
                    if (parNode.node.kmer in used && used[parNode.node.kmer] == curtime) {
                        continue;
                    }
                    parNode.node.edge[acidCode(parNode.nuc)] ~= edge;
                    parNode.node.coverCnt[acidCode(parNode.nuc)] += edgecnt;
                    nxt.parNodes ~= parNode;
                    used[parNode.node.kmer] = curtime;
                }
                swap(nodepos[cur.kmer], nodepos[nodes[$ - 1].kmer]);
                swap(nodes[i], nodes[$ - 1]);
                nodes.length -= 1;
                --i;
            } 
        } 
    }

    private string getComp(string read) {
        char[] result = read.dup;
        reverse(result);
        foreach (ref c; result) {
            c = complementary(c);
        }
        return cast(string)result;
    }

    private void addReadToGraph(string read) {
        if (!read.length) {
            return;
        }
        if (read.length <= ksize) {
            stderr.writeln("Skipped read cause it's length <= ksize: ", read);
            return;
        }
        if (!isValid(read)) {
            stderr.writeln("Invalid read: ", read);
            return;
        }
        string curkmer = read[0..ksize];
        Node curNode = createOrGetNode(curkmer);
        for (uint i = ksize + 1; i <= read.length; i++) {
            string nxtkmer = read[(i - ksize)..i];
            char nxtAcid = read[i - 1];
            Node nxtNode = createOrGetNode(nxtkmer);
            curNode.addEdge(nxtAcid);
            nxtNode.parNodes ~= ParNode(curNode, nxtAcid);
            curNode = nxtNode;
        }
    }

    private Node createOrGetNode(string kmer) {
        if (!(kmer in nodepos)) {
            nodes ~= new Node(kmer);
            nodepos[kmer] = nodes.length - 1;
        }
        return nodes[nodepos[kmer]];
    }

    private static bool isValid(string read) pure {
        return !(countchars(read, "^AC-IK-NP-TVWY"));
    }

    private static char complementary(char c) {
        switch (c) {
            case 'A':
                return 'T';
            case 'C':
                return 'G';
            case 'G':
                return 'C';
            case 'T':
                return 'A';
            default:
                assert(false);
        }
    }

    private static uint acidCode(char c) {
        switch (c) {
            case 'A':
                return 0;
            case 'C':
                return 1;
            case 'G':
                return 2;
            case 'T':
                return 3;
            default:
                assert(false);
        }
    }

    private static class Node {
        string kmer;
        char[][4] edge;
        int[4] coverCnt;
        ParNode[] parNodes;

        void addEdge(char acid) {
            int acidID = acidCode(acid);
            if (!edge[acidID].length) {
                edge[acidID] ~= acid;
            }
            coverCnt[acidID] += 1;
        }

        this(string kmer) {
            this.kmer = kmer;
        }
    }

}
