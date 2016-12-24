import std.stdio;
import std.string;
import std.conv;

import lib.spectra : Spectra;
import lib.sequencing : Sequencer;

private string peptide;
private int errorRate;
private int topPeptideOptimizationVal;
private int aminoAcidOptimizationVal;

class InvalideInputException : Exception 
{
    this(string msg) {
        super(msg);
    }
}

void checkAndCorrectPeptide() {
    import std.uni : toUpper;
    peptide = toUpper(peptide);
    if (countchars(peptide, "^AC-IK-NP-TVWY")) {
        throw new InvalideInputException("Invalid peptide! Expected a string representing peptide.");
    }
}

void checkErrorRate() {
    if (errorRate < 0 || errorRate > 100) {
        throw new InvalideInputException("Invalid error rate. Number from 0 to 100 expected.");
    }
}

string readChompedLine() {
    return chomp(stdin.readln());
}

void readData() {
    stdout.writeln("Cyclopeptide sequencing.");
    stdout.writeln("Enter peptide:");
    peptide = readChompedLine();
    checkAndCorrectPeptide();
    stdout.writeln("Error rate:");
    errorRate = to!int(readChompedLine());
    checkErrorRate();
    stdout.writeln("Number of temporary peptides to remain in brute-force:");
    topPeptideOptimizationVal = to!uint(readChompedLine());
    stdout.writeln("Number of amino acids to take as basis:");
    aminoAcidOptimizationVal = to!uint(readChompedLine());
}

void main() {
    try {
        readData();
    } catch (Exception e) {
        stderr.writeln("Invalid input!");
        stderr.writeln(e.msg);
        return;
    }

    auto spectra = new Spectra(peptide, errorRate);
    stdout.writeln(new Sequencer(spectra.getSortedSpectra(), spectra.getSortedAcidsFreq(), 
            spectra.getWeight(), topPeptideOptimizationVal, aminoAcidOptimizationVal).run());
}


