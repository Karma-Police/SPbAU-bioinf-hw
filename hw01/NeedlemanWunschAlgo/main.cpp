#include <iostream>
#include <cstdio>
#include <string>
#include <cassert>

using namespace std;

typedef long long ll;

const ll MAX_STRING_LENGTH = 1e4;
const ll INF = 1e8;
const ll MATCH_SCORE = -2;
const ll MISMATCH_PENALTY = 2;
const ll GAP_OPEN_PENALTY = 10;
const ll GAP_EXTENSION_PENALTY = 1;

struct history_record {
    int pos1;
    int pos2;
    bool isGap;
    bool isSpecified;
    history_record() : isSpecified(false) { }
    history_record(int _pos1, int _pos2, bool _isGap) : pos1(_pos1), pos2(_pos2), isGap(_isGap), isSpecified(true) { }
};

ll score[MAX_STRING_LENGTH][MAX_STRING_LENGTH];
history_record path[MAX_STRING_LENGTH][MAX_STRING_LENGTH];

void initialize(int n, int m) {
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= m; j++) {
            score[i][j] = INF;
        }
    }
    int cur_score = GAP_OPEN_PENALTY;
    for (int i = 1; i <= max(n, m); i++) {
        score[i][0] = cur_score;
        score[0][i] = cur_score;
        path[i][0] = history_record(0, 0, true);
        path[0][i] = history_record(0, 0, true);
        cur_score += GAP_EXTENSION_PENALTY;
    }
    score[0][0] = 0;
}

void calculate_score(const string & s1, const string & s2) {
    int n = s1.length();
    int m = s2.length();
    initialize(n, m);
    
    for (int i = 0; i <= n; i++) {
        for (int j = 0; j <= m; j++) {
            if (i && j && s1[i - 1] == s2[j - 1] && score[i - 1][j - 1] + MATCH_SCORE < score[i][j]) {
                score[i][j] = score[i - 1][j - 1] + MATCH_SCORE;
                path[i][j] = history_record(i - 1, j - 1, false);
            }
            if (i && j && score[i - 1][j - 1] + MISMATCH_PENALTY < score[i][j]) {
                score[i][j] = score[i - 1][j - 1] + MISMATCH_PENALTY;
                path[i][j] = history_record(i - 1, j - 1, false);
            }
            int cur_score_bonus = GAP_OPEN_PENALTY;
            for (int k = i; i && k <= n; k++) {
                if (score[k][j] > score[i - 1][j] + cur_score_bonus) {
                    score[k][j] = score[i - 1][j] + cur_score_bonus;
                    path[k][j] = history_record(i - 1, j, true);
                }
                cur_score_bonus += GAP_EXTENSION_PENALTY;
            }
            cur_score_bonus = GAP_OPEN_PENALTY;
            for (int k = j; j && k <= m; k++) {
                if (score[i][k] > score[i][j - 1] + cur_score_bonus) {
                    score[i][k] = score[i][j - 1] + cur_score_bonus;
                    path[i][k] = history_record(i, j - 1, true);
                }
                cur_score_bonus += GAP_EXTENSION_PENALTY;
            }
        }
    }
}

void print_matching(const string & s, bool id, int x, int y) {
    if (x == 0 && y == 0) {
        return;
    }
    assert(path[x][y].isSpecified);
    if (!path[x][y].isGap) {
        print_matching(s, id, x - 1, y - 1);
        if (id) {
            cout << s[x - 1];
        } else {
            cout << s[y - 1];
        }
        return;
    }
    if (path[x][y].pos1 != x) {
        assert(path[x][y].pos2 == y);
        print_matching(s, id, path[x][y].pos1, path[x][y].pos2);
        for (int i = path[x][y].pos1 + 1; i <= x; i++) {
            if (!id) {
                cout << "-";
            } else {
                cout << s[i];
            }
        }
    } else {
        assert(path[x][y].pos2 != y);
        print_matching(s, id, path[x][y].pos1, path[x][y].pos2);
        for (int i = path[x][y].pos2 + 1; i <= y; i++) {
            if (id) {
                cout << "-";
            } else {
                cout << s[i];
            }
        }
    }
}

int main() {
    string s1, s2;
    cin >> s1 >> s2;

    if (s1.length() >= MAX_STRING_LENGTH || s2.length() >= MAX_STRING_LENGTH) {
        cout << "Input string is too large!" << endl;
        return 0;
    }

    calculate_score(s1, s2);    

    cout << "Score: " << score[s1.length()][s2.length()] << endl;
    print_matching(s1, true, s1.length(), s2.length());
    cout << endl;
    print_matching(s2, false, s1.length(), s2.length());
    cout << endl;
    return 0;
}


