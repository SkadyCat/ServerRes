#include <unordered_map>

#include "help.h"
#include <fstream>
#include <string>
#include <unordered_map>
using namespace std;
extern "C"
{
	#include "lua.h"  
	#include "lualib.h"  
	#include "lauxlib.h"  
}
const std::string WHITESPACE = " \n\r\t\f\v";


static std::string ltrim(const std::string &s)
{
	size_t start = s.find_first_not_of(WHITESPACE);
	return (start == std::string::npos) ? "" : s.substr(start);
}

static std::string rtrim(const std::string &s)
{
	size_t end = s.find_last_not_of(WHITESPACE);
	return (end == std::string::npos) ? "" : s.substr(0, end + 1);
}

static std::string trim(const std::string &s) {
	return rtrim(ltrim(s));
}

static queue<string> load(string path)
{
	ifstream ifs(path);
	string line;
	string process;
	bool flag = false;
	queue<string> q;
	if (ifs.is_open())
	{
		while (getline(ifs, line))
		{
			string tt = trim(line);
			q.push(tt);
		}
		ifs.close();
	}
	return q;
}

static vector<string> split(string s, string delimiter) {
	size_t pos_start = 0, pos_end, delim_len = delimiter.length();
	string token;
	vector<string> res;

	while ((pos_end = s.find(delimiter, pos_start)) != string::npos) {
		token = s.substr(pos_start, pos_end - pos_start);
		pos_start = pos_end + delim_len;
		res.push_back(token);
	}

	res.push_back(s.substr(pos_start));
	return res;
}

static int _new(lua_State* L){
	
	
	return 1;
}
static int _load(lua_State* L) {
	string path = luaL_checkstring(L, 1);
	size_t a = 0;
	luaL_checklstring(L, 1, &a);
	queue<string> lines = load(path);
	string keys = lines.front();
	lines.pop();
	vector<string> keySets = split(keys, ",");
	vector<unordered_map<string, string>> pp;
	while (lines.size() != 0) {
		keys = lines.front();
		lines.pop();
		vector<string> values = split(keys, ",");
		unordered_map<string, string> tp;
		for (int i = 0; i < keySets.size(); i++) {
			tp[keySets[i]] = values[i];
		}
		pp.push_back(tp);
	}
	addVectorArr2v(L,pp);
	return 1;
}
static int test(lua_State* L) {


	vector<sdmap> sp;
	sdmap s1;

	s1["x"] = 1;
	s1["y"] = 2;
	s1["z"] = 3;
	sp.push_back(s1);
	s1["x"] = 4;
	s1["y"] = 5;
	s1["z"] = 6;
	sp.push_back(s1);

	addVectorArr(L, sp);

	return 1;
}

static int _equal(lua_State * L) {
	sdmap sp = checkTable(L);

	sp = checkTable(L);
	return 1;
}
static int _dis(lua_State * L) {
	sdmap sp = checkTable(L);
	sp = checkTable(L);
	return 1;
}

static luaL_Reg luaLibs[] =
{
	{"read", _load},
	{ NULL, NULL }
};


#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
//define something for Windows (32-bit and 64-bit, this part is common)
extern "C"  __declspec(dllexport) int luaopen_Csvparse(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
#ifdef _WIN64
	
#endif

#if __linux__
extern "C"  int luaopen_Csvparse(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
