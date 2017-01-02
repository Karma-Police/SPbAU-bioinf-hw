import std.stdio;
import std.algorithm;
import std.string;
import std.conv;
import std.typecons;

private static immutable int MAXK = 4;

private int[] s1, s2;

alias Tuple!(int, "i", int, "j") IJ;

void readinput() {
    stdout.writeln("First spectra:");
    split(chomp(stdin.readln())).each!(s => s1 ~= to!int(s));
    stdout.writeln("Second spectra:");
    split(chomp(stdin.readln())).each!(s => s2 ~= to!int(s));
}

void main()
{
    readinput();
    assert(isStrictlyMonotonic(s1));
    assert(isStrictlyMonotonic(s2));

    ulong n = s1.length;
    ulong m = s2.length;
    int[][][] dp = new int[][][](MAXK, n, m);
    int[][][] M = new int[][][](MAXK, n, m);
    int[MAXK] maxans;
    IJ[int] diag;

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            for (int k = 1; k < MAXK; k++) {
                int curbal = s1[i] - s2[j];
                if (curbal in diag) {
                    dp[k][i][j] = dp[k][diag[curbal].i][diag[curbal].j] + 1;
                }
                if (i && j) {
                    dp[k][i][j] = max(dp[k][i][j], M[k - 1][i - 1][j - 1] + 1); 
                } else {
                    dp[k][i][j] = 1;
                }
                M[k][i][j] = dp[k][i][j];
                if (i) M[k][i][j] = max(M[k][i][j], M[k][i - 1][j]);
                if (j) M[k][i][j] = max(M[k][i][j], M[k][i][j - 1]);
                maxans[k] = max(maxans[k], dp[k][i][j]);
            }
            diag[s1[i] - s2[j]] = IJ(i, j);
        }
    }
    stdout.writeln(maxans);
}
