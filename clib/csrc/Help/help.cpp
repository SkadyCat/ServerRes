#include "help.h"


//int addTableArray(lua_State* L_, int size, sdmap* map)
//{
//	lua_newtable(L_);
//	int i = 1;
//
//	for (int i = 1; i < size; i++)
//	{
//		lua_pushnumber(L_, i);
//		lua_newtable(L_);
//
//		sdmap::iterator it = map[i - 1].begin();
//		while (it != map[i - 1].end()) {
//			lua_pushstring(L_, it->first.c_str());
//			lua_pushnumber(L_, it->second);
//			lua_settable(L_, -3);
//			it++;
//		}
//		lua_settable(L_, -3);
//	}
//	delete[] map;
//	return 1;
//}
//
//


void addVectorArr(lua_State* L, vector<sdmap>& vsp) {
	lua_newtable(L);
	int i = 1;
	for (int i = 0; i < vsp.size(); i++)
	{
		lua_pushnumber(L, i);
		lua_newtable(L);
		sdmap& map = vsp[i];
		sdmap::iterator it = map.begin();
		while (it != map.end()) {
			lua_pushstring(L, it->first.c_str());
			lua_pushnumber(L, it->second);
			lua_settable(L, -3);
			it++;
		}
		lua_settable(L, -3);
	}
}

void addVectorArr2v(lua_State* L, vector<unordered_map<string, string>>& vsp) {
	lua_newtable(L);
	int i = 1;
	for (int i = 0; i < vsp.size(); i++)
	{
		lua_pushnumber(L, i);
		lua_newtable(L);
		unordered_map<string, string>& map = vsp[i];
		unordered_map<string, string>::iterator it = map.begin();
		while (it != map.end()) {
			lua_pushstring(L, it->first.c_str());
			lua_pushstring(L, it->second.c_str());
			lua_settable(L, -3);
			it++;
		}
		lua_settable(L, -3);
	}
}