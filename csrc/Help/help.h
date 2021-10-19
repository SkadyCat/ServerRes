

#pragma once

#include<iomanip>
#include <iostream>
#include <unordered_map>
#include <queue>
#include <vector>
extern "C"
{
	#include "lua.h"  
	#include "lualib.h"  
	#include "lauxlib.h"  
}
using namespace std;


typedef unordered_map<string, double> sdmap;
static sdmap checkTable(lua_State* L) {

	
		lua_pushnil(L);
		sdmap sdp;
		while (lua_next(L, 1) != 0)
		{

			
			sdp.insert({ lua_tostring(L, -2) , lua_tonumber(L, -1) });
			lua_pop(L, 1);
		}
		lua_remove(L, 1);
		return sdp;
	
}

static int addTableArray(lua_State* L_, int size, sdmap* map);



static string checkString(lua_State* L) {
	string v1 = luaL_checkstring(L, 1);
	lua_remove(L, 1);
	return v1;
}
static int checkInteger(lua_State* L) {
	int v1 = luaL_checkinteger(L, 1);
	lua_remove(L, 1);
	return v1;
}

static void addDic(lua_State* L, sdmap& mp) {

	sdmap::iterator it = mp.begin();
	lua_newtable(L);
	while (it != mp.end()) {
		string data = it->first;
		lua_pushstring(L, data.c_str());
		lua_pushnumber(L, it->second);
		lua_settable(L, -3);//
		it++;
	}
}
static void addArray(lua_State* L, int* data, int& size) {

	unordered_map<int, int> map;

	for (int i = 0; i < size; i++) {
		map.insert({ data[i],i });
	}

	lua_newtable(L);
	lua_pushnumber(L, -1);
	lua_rawseti(L, -2, 0);
	unordered_map<int, int>::iterator it = map.begin();
	int n = 0;
	while (it != map.end()) {

		
		lua_pushnumber(L, data[n]);
		lua_rawseti(L, -2, n + 1);
		n++;
		it++;
	}

}
static void addArray(lua_State* L, float* data, int& size) {

	lua_newtable(L);
	lua_pushnumber(L, -1);
	lua_rawseti(L, -2, 0);
	for (int n = 0; n < size; n++) {
		lua_pushnumber(L, data[n]);      
		lua_rawseti(L, -2, n + 1);
	}
}
static void addArray(lua_State* L,vector<int>& data) {
	
	lua_newtable(L);
	lua_pushnumber(L, -1);
	lua_rawseti(L, -2, 0);
	for (int n = 0; n < data.size(); n++) {
		lua_pushinteger(L, data[n]);       
		lua_rawseti(L, -2, n + 1);
	}
}
static void addArray(lua_State* L, vector<string>& data) {

	lua_newtable(L);
	lua_pushnumber(L, -1);
	lua_rawseti(L, -2, 0);
	for (int n = 0; n < data.size(); n++) {
		lua_pushlstring(L, data[n].c_str(),data[n].size());
		lua_rawseti(L, -2, n + 1);
	}
}

void addVectorArr(lua_State* L, vector<sdmap>& vsp);

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
static void addBuffer(lua_State* L, vector<char>& vsp) {

	char* data = new char[vsp.size()];
	for (int i = 0; i < vsp.size(); i++) {
		data[i] = vsp[i];
	}
	lua_pushlstring(L, data, vsp.size());
	delete[] data;
}
static void addVectorArr4(lua_State* L, vector<vector<int>>& vsp){

	lua_newtable(L);
	int i = 1;
	for (int i = 0; i < vsp.size(); i++)
	{
		lua_pushnumber(L, i);
		lua_newtable(L);
		sdmap map;
		map["code"] = vsp[i][0];
		map["type"] = vsp[i][1];
		map["self"] = vsp[i][2];
		map["other"] = vsp[i][3];
		map["st"] = vsp[i][4];
		map["ot"] = vsp[i][5];
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
