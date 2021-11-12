



#include "Aoi.h"
#include "AoiEntity.h"
#include "AoiTrigger.h"
#include "AoiContext.h"
#include <vector>
#include<stdio.h>
#include<stdlib.h>
#include <iostream>
#include "help.h"
#include <unordered_map>


using namespace std;
typedef struct  scene_t
{
	AoiContext* g_context;
}scene;

//int main() {
//	int width = 1024;
//	int height = 500;
//
//	AoiContext* context = new AoiContext(width, height, 10);
//	
//	/*for (int i = 0; i < 1000; i++) {
//		context->CreateEntity();
//	}*/
//
//	for (int i = 0; i < 20; i++) {
//		context->CreateTriggerMarker(i);;
//	}
//
//
//	while (true)
//	{
//
//		cout << "hello world" << endl;
//		_sleep(100);
//
//	}
//	return 0;
//}




static int newScene(lua_State*L) {

	
	// scene** pAoi = static_cast<scene **>(lua_newuserdata(L, sizeof(*pAoi)));
	scene* pAoi = new scene();
	lua_pushlightuserdata(L,pAoi);
	// luaL_setmetatable(L, "Foo");
	
	printf("new --- %x\n",pAoi);
	( pAoi)->g_context = new AoiContext(2000, 2000, 10);
	( pAoi)->g_context->lua = L;
	return 1;
}
static int setEntityCall(lua_State*L) {
	// scene* pAoi = (scene*) lua_touserdata(L,1);
	// pAoi->g_context->lua = L;
	// (pAoi)->g_context->entityRef = luaL_ref(L, LUA_REGISTRYINDEX);
	return 0;
}
static int setTriggerCall(lua_State*L) {
	// scene* pAoi = (scene*)lua_touserdata(L, 1);

	// printf("-------------set entity 2 %x\n",pAoi);
	// pAoi->g_context->triggerRef = luaL_ref(L, LUA_REGISTRYINDEX);
	return 0;
}

static int createSpace(lua_State* L) {
	//g_context = new AoiContext(2000, 2000, 10);

	return 0;
}

static int add(lua_State* L) {
	printf("add user");
	scene* sc = (scene*)lua_touserdata(L, 1);
	AoiContext* g_context = sc->g_context;

	printf("add user");
	int id = luaL_checkinteger(L, 2);
	printf("add user%d\n",id);
	float x = luaL_checknumber(L, 3);
	float z = luaL_checknumber(L, 4);
	float range = luaL_checknumber(L, 5);
	g_context->CreateTriggerMarker(id,x,z,range);
	int type = luaL_checkinteger(L,6);
	//(*maps)[id] = type;
	g_context->userMap[id] = type;
	return 0;
}

static int match(lua_State* L){
	scene* sc = (scene*)lua_touserdata(L, 1);
	AoiContext* g_context = sc->g_context;
	int id = luaL_checkinteger(L, 2);
	return 1;
}
static int remove(lua_State* L) {
	scene* sc = (scene*)lua_touserdata(L, 1);
	AoiContext* g_context = sc->g_context;
	int id = luaL_checkinteger(L, 2);
	g_context->remove(id);
	delete sc;
	return 0;

}
static int update(lua_State* L) {
	scene* sc = (scene*)lua_touserdata(L, 1);
	AoiContext* g_context = sc->g_context;
	int id = luaL_checkinteger(L, 2);
	float x = luaL_checknumber(L, 3);
	float z = luaL_checknumber(L, 4);
	g_context->setPos(id, x, z);
	//printf("set success.........");
	// vector<int> arr = g_context->range(id);
	addVectorArr4(L,g_context->vecList);
	g_context->vecList.clear();
	return 1;
}
static int info(lua_State* L) {
	scene* sc = (scene*)lua_touserdata(L, 1);
	AoiContext* g_context = sc->g_context;
	int id = luaL_checkinteger(L, 2);
	Aoi* aoi = g_context->wm_list[id];
	lua_pushstring(L,aoi->info().c_str());
	return 1;

}
static luaL_Reg luaLibs[] =
{
	{"add", add },
	{"update", update},
	{"createSpace",createSpace},
	{"remove",remove},
	{"info",info},
	{"type",match},
	{"new",newScene},
	{"setecall",setEntityCall},
	{"settcall",setTriggerCall},
	{ NULL, NULL }
};


#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
//define something for Windows (32-bit and 64-bit, this part is common)
extern "C"  __declspec(dllexport) int luaopen_laoi(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#ifdef _WIN64
//define something for Windows (64-bit only)

#else
//define something for Windows (32-bit only)
#endif
#elif __APPLE__
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR
// iOS Simulator
#elif TARGET_OS_IPHONE
// iOS device
#elif TARGET_OS_MAC
// Other kinds of Mac OS
#else
#   error "Unknown Apple platform"
#endif
#elif __linux__
// linux
extern "C"  int luaopen_laoi(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#elif __unix__ // all unices not caught above
// Unix
#elif defined(_POSIX_VERSION)
// POSIX
#else
#   error "Unknown compiler"
#endif