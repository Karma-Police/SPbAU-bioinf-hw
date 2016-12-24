module lib.sequencing;

import std.algorithm;
import std.array;
import std.typecons : Tuple;

import lib.spectra : AcidWeight, Spectra;

alias Tuple!(string, "curpep", long, "weight") TmpPep;

public class Sequencer {
    private const long[] spectra;
    private const long[] acidFreq;
    private const long weight;
    private const int topN;

    public this(const long[] spectra, const long[] acidFreq, 
            long weight, int topN, int acidM) {
        assert(isSorted(spectra));
        assert(isSorted(acidFreq));
        this.spectra = spectra;
        this.acidFreq = acidFreq[0..acidM];
        this.weight = weight;
        this.topN = topN;
    }

    public string run() {
        auto queue = [TmpPep("", 0)];
        auto expandDg = &expandPep;
        auto scoreDg = &score;
        long bestScore = 0;
        string bestPep = "";
        while (queue.length) {
            queue = array(queue.map!(expandDg).join().filter!(t => t.weight <= weight)); 
            foreach (TmpPep t; queue) {
                assert(t.weight <= weight);
                if (t.weight == weight) {
                    long curScore = score(t.curpep);
                    if (curScore > bestScore) {
                        bestScore = curScore;
                        bestPep = t.curpep;
                    }
                }
            }
            queue = array(queue.topN!((t1, t2) => scoreDg(t1.curpep) > scoreDg(t2.curpep))(topN));
        }
        return bestPep;
    }

    private long score(string pep) {       
        auto tmpData = new Spectra(pep, 0).getSortedSpectra();
        return setIntersection(tmpData, spectra).count; 
    }

    private auto expandPep(TmpPep t) {
        TmpPep[] res;
        auto app = appender(res);
        for (char c = 'A'; c <= 'Z'; c++) {
            long cweight = AcidWeight[Spectra.alphaId(c)];
            if (cweight) {
                app.put(TmpPep(t.curpep ~ c, t.weight + cweight)); 
            }
        }
        return app.data;
    };
}


