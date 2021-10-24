

#include <unordered_map>
#include "Scene.h"
#include "help.h"

#include <iostream>
using namespace std;
extern "C"
{
	#include "lua.h"  
	#include "lualib.h"  
	#include "lauxlib.h"  
}
static int load(lua_State * L) {
	string path = luaL_checkstring(L, 1);
	Scene* sc = new Scene(path);
	lua_pushlightuserdata(L, sc);
	return 1;
}

static sdmap convertVec3ToSdmp(Vector3 vec) {
	sdmap mp;
	mp["x"] = vec.x;
	mp["y"] = vec.y;
	mp["z"] = vec.z;
	return mp;
}
static void addVector3Arr(lua_State* L, vector<Vector3>& vsp) {
	lua_newtable(L);
	int i = 1;
	for (int i = 0; i < vsp.size(); i++)
	{
		lua_pushnumber(L, i);
		lua_newtable(L);
		sdmap map = convertVec3ToSdmp(vsp[i]);
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

static int findPath(lua_State * L) {
	Scene* sc = (Scene*)lua_touserdata(L, 1);
	lua_remove(L, 1);
	sdmap v1 = checkTable(L);
	sdmap v2 = checkTable(L);
	Vector3 v3(v1["x"],v1["y"],v1["z"]);
	Vector3 v4(v2["x"],v2["y"],v2["z"]);
	vector<Vector3> v5 = sc->findPath(v3, v4);
	addVector3Arr(L, v5);
	return 1;
}
static luaL_Reg luaLibs[] =
{
	{"load", load },
	{"findPath", findPath},
	{ NULL, NULL }
};


#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
extern "C"  __declspec(dllexport) int luaopen_NavCore(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
#ifdef _WIN64

#endif

#if __linux__
extern "C"  int luaopen_BufferReader(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
