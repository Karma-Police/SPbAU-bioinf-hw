import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.algorithm;
import std.range;
import std.typecons;

private int[] ionTypes;
private int[] spectra;
private int strongPeakSz;

public static immutable AcidWeight = 
    [71, 0, 113, 115, 129, 147, 57, 137, 113, 0, 128, 113, 131, 114, 0, 
    97, 128, 156, 87, 101, 0, 99, 186, 0, 163, 0];

public static immutable int MaxWeight = 187;

void readInput() {
    stdout.writeln("Ion types:");
    string[] ions = split(stdin.readln());
    stdout.writeln("Spectra:");
    string[] spectr = split(stdin.readln());
    stdout.writeln("Strong peak size:");
    strongPeakSz = to!int(chomp(stdin.readln()));
    ions.each!(s => ionTypes ~= to!int(chomp(s)));
    spectr.each!(s => spectra ~= to!int(chomp(s)));

}

alias Tuple!(int, "from", int, "to", int, "weight") Edge;

void main() {
    readInput();
    if (ionTypes.find(0).empty) {
        ionTypes ~= 0;
    }
    int[] resultSpectra;
    foreach (int peak; spectra) {
        foreach (int ion; ionTypes) {
            int res = peak + ion;
            resultSpectra ~= res;
        }
    }
    resultSpectra ~= 0;
    resultSpectra.sort();
    int[] peptideLadder = resultSpectra.group().filter!(a => a[1] >= strongPeakSz || a[0] == 0).map!(a => a[0]).array();
    stdout.writeln("peptide ladder after strong peak analysis:");
    stdout.writeln(peptideLadder);

    Edge[] edges;
    for (int i = 0; i < peptideLadder.length; i++) {
        foreach (int acid; AcidWeight) {
            if (!acid) continue;
            int nxt = peptideLadder[i] + acid;
            for (int j = i + 1; j < peptideLadder.length; j++) {
                if (peptideLadder[j] == nxt) {
                    edges ~= Edge(i, j, acid);
                }
                if (peptideLadder[j] > nxt) {
                    break;
                }
            }
        }
    }
    
    stdout.writeln("Graph:");
    edges.each!(e => stdout.writeln("(" ~ to!string(e.from) ~ " ->  " ~ to!string(e.to) ~ ", weight = " ~ to!string(e.weight) ~ ")"));
}
