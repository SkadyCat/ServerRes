#include <unordered_map>
#include "aoi.h"
#include "help.h"
#include <fstream>
#include <string>
#include <unordered_map>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


using namespace std;
extern "C"
{
#include "lua.h"  
#include "lualib.h"  
#include "lauxlib.h"  
}
struct alloc_cookie {
	int count;
	int max;
	int current;
};

static void *
my_alloc(void * ud, void *ptr, size_t sz) {
	struct alloc_cookie * cookie = (alloc_cookie*)ud;
	if (ptr == NULL) {
		void *p = malloc(sz);
		++cookie->count;
		cookie->current += sz;
		if (cookie->max < cookie->current) {
			cookie->max = cookie->current;
		}
		//		printf("%p + %u\n",p, sz);
		return p;
	}
	--cookie->count;
	cookie->current -= sz;
	//	printf("%p - %u \n",ptr, sz);
	free(ptr);
	return NULL;
}

struct OBJECT {
	float pos[3];
	char mode[4];
	int flag = 0;
};

struct SCENE
{
	alloc_cookie cookie = { 0,0,0 };
	aoi_space * space;
	OBJECT items[1024];
};

static void message(void *ud, uint32_t watcher, uint32_t marker) {
	//printf("%u (%f,%f) => %u (%f,%f)\n",
	//	watcher, OBJ[watcher].pos[0], OBJ[watcher].pos[1],
	//	marker, OBJ[marker].pos[0], OBJ[marker].pos[1]
	//);
	cout << "watcher: " << watcher << ", marker: " << marker << endl;
}

static int _new(lua_State* L) {
	SCENE * sc = new SCENE();
	sc->space = aoi_create(my_alloc, &sc->cookie);
	lua_pushlightuserdata(L, sc);
	return 1;
}





static int add(lua_State* L) {
	SCENE* sc = (SCENE*)lua_touserdata(L, 1);
	string mode = luaL_checkstring(L, 2);
	float x = luaL_checknumber(L, 3);
	float y = luaL_checknumber(L, 4);
	int index = 0;
	for (int i = 0; i < 1024; i++) {
		if (sc->items[i].flag == 0) {
			index = i;
			break;
		}
	}
	OBJECT& item = sc->items[index];

	item.flag = 1;
	item.pos[0] = x;
	item.pos[1] = y;
	item.pos[2] = 0;
	strcpy(item.mode, mode.c_str());
	aoi_update(sc->space, index, item.mode, item.pos);
	lua_pushinteger(L, index);
	aoi_message(sc->space,message,NULL);
	return 1;
}

static int update(lua_State * L) {
	
	SCENE* sc = (SCENE*)lua_touserdata(L, 1);
	int index = luaL_checkinteger(L, 2);
	OBJECT& item = sc->items[index];
	float x = luaL_checknumber(L, 3);
	float y = luaL_checknumber(L, 4);
	item.pos[0] = x;
	item.pos[1] = y;
	item.pos[2] = 0;
	cout<<"??--1111111111"<<endl;
	cout<<"pos:"<<x<<","<<y<<endl;
	aoi_update(sc->space, index, item.mode, item.pos);
	aoi_message(sc->space, message, NULL);

	return 0;
}
static int remove(lua_State* L) {
	SCENE* sc = (SCENE*)lua_touserdata(L, 1);
	int index = luaL_checkinteger(L, 2);
	OBJECT& item = sc->items[index];
	item.flag = 0;
	
	return 0;
}

static int clear(lua_State* L) {
	SCENE* sc = (SCENE*)lua_touserdata(L, 1);
	aoi_release(sc->space);
	delete sc;
	return 0;
}

static luaL_Reg luaLibs[] =
{
	{"new",_new},
	{"add", add},
	{"remove",remove},
	{"update",update},
	{"clear",clear},
	{ NULL, NULL }
};


#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
//define something for Windows (32-bit and 64-bit, this part is common)
extern "C"  __declspec(dllexport) int luaopen_Aoi(lua_State * L)
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
