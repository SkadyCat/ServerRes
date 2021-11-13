

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

static int setSpeed(lua_State * L) {
	
	float sd = luaL_checknumber(L, 1);
	Sample::stepSize = sd;

	return 0;

}
static int findPath(lua_State * L) {
	Scene* sc = (Scene*)lua_touserdata(L, 1);
	float x1 = -luaL_checknumber(L,2);
	float y1 = luaL_checknumber(L,3);
	float z1 = luaL_checknumber(L,4);
	float x2 = -luaL_checknumber(L,5);
	float y2 = luaL_checknumber(L,6);
	float z2 = luaL_checknumber(L,7);
	Vector3 v3(x1,y1,z1);
	Vector3 v4(x2,y2,z2);

	vector<Vector3> v5 = sc->findPath(v3, v4);
	// cout << v3.x << " " << v3.y << " " << v3.z << endl;
	// cout << v4.x << " " << v4.y << " " << v4.z << endl;
	// cout<<"the path size = "<<v5.size()<<endl;
	addVector3Arr(L, v5);
	return 1;
}
static luaL_Reg luaLibs[] =
{
	{"load", load },
	{"findPath", findPath},
	{"setSpeed",setSpeed},
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
extern "C"  int luaopen_NavCore(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
