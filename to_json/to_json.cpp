#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <ctime>
#include <stdio.h>

using namespace std;
void split(const string &s, const char* delim, vector<string> & v);
string ZeroPadNumber(string num);

void main()
{

	time_t rawtime;
	struct tm * timeinfo;
	char buffer[80];
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(buffer, sizeof(buffer), "%d.%m.%Y %I:%M:%S", timeinfo);
	std::string test_date(buffer);



	ifstream in("bbox_temp.txt");
	string path, fps, bbox_temp, width, height;
	in >> path;
	in >> fps;
	in >> width;
	in >> height;



	vector<string> temp;
	split(path, "\\", temp);
	string date = temp[temp.size() - 1];
	string route_pos = temp[temp.size() - 3];
	string route;

	for (int i = 0; i < route_pos.length(); i++)
	{
		if (isdigit(route_pos[i]))
			route = route + route_pos[i];
	}


	string pos;
	if (temp[temp.size() - 3].find("left"))
		pos = "left";
	else if (temp[temp.size() - 3].find("right"))
		pos = "right";
	else if (temp[temp.size() - 3].find("center"))
		pos = "center";
	else
		pos = "undefined";


	string resolution = width + '*' + height;
	string items, frame_number, rois;

	//do first time for putting ',' at right place
	if (!in.eof())
	{
		in >> frame_number;
		in >> rois;
		items = items + "				 { \"frame_number\":\"" + ZeroPadNumber(frame_number) + ".jpg\", \n"
			          + "				   \"RoIs\":\"" + rois + "\"}\n";
    }

	while ( !in.eof()) {

		in >> frame_number;
		in >> rois;
		items = items + "				 ,{ \"frame_number\":\"" + ZeroPadNumber(frame_number) + ".jpg\",\n"
					  +	"				   \"RoIs\":\"" + rois + "\"}\n";
	}
	in.close();

	string json;
	json = json + "{ \"optput\":                                               \n";
	json = json + "		{ \"video_cfg\":                                       \n";
	json = json + "			{\"datetime\":\"" + date + "\",                    \n";
	json = json + "			 \"route\":\"" + route + "\",                      \n";
	json = json + "			 \"com_pos\":\"" + pos + "\",                      \n";
	json = json + "			 \"fps\":\"" + fps + "\",                          \n";
	json = json + "			 \"resolution\":\"" + width + 'x' + height + "\"   \n";
	json = json + "			},                                                 \n";
	json = json + "		  \"framework\":                                       \n";
	json = json + "			{\"name\":\"darknet\",			                   \n";
	json = json + "			 \"version\":\"2018mar01\",			               \n";
	json = json + "			 \"test_date\":\""+ test_date+ +"\"		           \n";
	json = json + "			},			                                       \n";
	json = json + "		  \"frames\":[                                         \n";
	json = json +				items +       	      						  "\n";
	json = json + "					 ]                                         \n";
	json = json + "     }                                                      \n";
	json = json + "}	                                                       \n";

	ofstream myfile;

	vector<string> temp_path;
	split(path, ".", temp_path);

	myfile.open(temp_path[0]+".json");
	myfile << json;
	myfile.close();
}


void split(const string &s, const char* delim, vector<string> & v) {

	char * dup = _strdup(s.c_str());
	char * token = strtok(dup, delim);
	while (token != NULL) {
		v.push_back(string(token));
		token = strtok(NULL, delim);
	}
	free(dup);
}


string ZeroPadNumber(string num)
{
	stringstream ss;

	// the number is converted to string with the help of stringstream
	ss << num;
	string ret;
	ss >> ret;

	// Append zero chars
	int str_length = ret.length();
	for (int i = 0; i < 7 - str_length; i++)
		ret = "0" + ret;
	return ret;
}