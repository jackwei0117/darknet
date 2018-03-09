#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>

using namespace std;

void to_json();
void split(const string &s, const char* delim, vector<string> & v);
int extractIntegerWords(string str);
