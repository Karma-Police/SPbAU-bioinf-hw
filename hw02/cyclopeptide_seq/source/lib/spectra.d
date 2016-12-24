module lib.spectra;

import std.string;
import std.array;
import std.random;
import std.algorithm : sort;

// Taken from presentation. It's different from wikipedia's table.
public static immutable AcidWeight = 
    [71, 0, 113, 115, 129, 147, 57, 137, 113, 0, 128, 113, 131, 114, 0, 
    97, 128, 156, 87, 101, 0, 99, 186, 0, 163, 0];

public static immutable acidWeightUpperBound = 187;

public class Spectra
{
    private immutable string peptidex2;
    private immutable ulong originalPeptLen;
    private immutable int errorRate;

    private auto rndGen = MinstdRand0(1); // same random for same input
    private long[] spectra;
    private long[] acidsFreq;
    private long peptideWeight = 0;

    public this(string peptide, int errorRate) {
        assert(countchars(peptide, "^AC-IK-NP-TVWY") is 0);
        this.originalPeptLen = peptide.length;
        this.peptidex2 = peptide ~ peptide;
        this.errorRate = errorRate;
        calculateSpectra();
        calculateAcidFreq();
    }

    public const(long[]) getSortedSpectra() const nothrow {
        return spectra;
    }

    public long getWeight() const nothrow {
        return peptideWeight;
    }

    public const(long[]) getSortedAcidsFreq() const nothrow {
        return acidsFreq;
    }

    private void calculateSpectra() {
        auto app = appender(spectra);
        for (ulong i = 0; i < originalPeptLen; i++) {
            long curWeight = 0;
            peptideWeight += AcidWeight[alphaId(peptidex2[i])];
            for (ulong j = i; j < i + originalPeptLen - 1; j++) {
                curWeight += AcidWeight[alphaId(peptidex2[j])];
                app.put(curWeight);
            }
        }
        spectra = app.data;
        for (ulong i = 0; i < spectra.length; i++) {
            if (nextRand() % 100 < errorRate) {
                spectra[i] += cast(int)(nextRand() % 150) - 75;
            } 
        }
        spectra.sort();
    }

    private void calculateAcidFreq() {
        for (char a = 'A'; a <= 'Z'; a++) {
            if (!AcidWeight[alphaId(a)]) continue;
            long cnt = 0;
            for (ulong i = 0; i < spectra.length; i++) {
                for (ulong j = i + 1; j < spectra.length && spectra[j] - spectra[i] < acidWeightUpperBound; j++) {
                   cnt += (AcidWeight[alphaId(a)] == spectra[j] - spectra[i]);
                }
            }
            acidsFreq ~= cnt;
        }
        acidsFreq.sort();
    }

    private uint nextRand() {
        uint res = rndGen.front;
        rndGen.popFront();
        return res;
    }

    static public int alphaId(char c) pure nothrow {
        return c - 'A';
    }

    override
    public string toString() const {
        return peptidex2[0..originalPeptLen];
    }
}


