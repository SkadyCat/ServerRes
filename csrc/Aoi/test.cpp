
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern "C"
{
#include "aoi.h"
 

}
#define DLL_EXOPRT  extern "C" __declspec(dllexport)

static int counter = 0;

static void call_back(void* _pAoi,bool flag,int watcher,int marker);

// extern "C"
// {


// }

typedef struct aoi_s
{
	/* data */
    aoi_space *	pHandle;
	int32_t			iRef;
	lua_State*      pLuaState;
	//aoi_s(aoi_space * p1, int32_t ref, lua_State* ls) {
	//	pHandle = p1;
	//	iRef = ref;
	//	pLuaState = ls;
	//}
}aoi_tt;
struct alloc_cookie {
	int count;
	int max;
	int current;
};

static aoi_tt* instance = NULL;
static aoi_space * _space;


static void *
my_alloc(void * ud, void *ptr, size_t sz) {
	struct alloc_cookie * cookie = (alloc_cookie*)ud;
	if (ptr == NULL) {
		void *p = malloc(sz);
		++ cookie->count;
		cookie->current += sz;
		if (cookie->max < cookie->current) {
			cookie->max = cookie->current;
		}
//		printf("%p + %u\n",p, sz);
		return p;
	}
	-- cookie->count;
	cookie->current -= sz;
//	printf("%p - %u \n",ptr, sz);
	free(ptr);
	return NULL;
}

struct OBJECT {
	float pos[3];
	float v[3];
	char mode[4];
};

static struct OBJECT OBJ[1024];

static void
init_obj(uint32_t id, float x, float y, float vx, float vy, const char *mode) {
	OBJ[id].pos[0] =x;
	OBJ[id].pos[1] =y;
	OBJ[id].pos[2] =0;

	OBJ[id].v[0] =vx;
	OBJ[id].v[1] =vy;
	OBJ[id].v[2] =0;

	strcpy(OBJ[id].mode, mode);
}
static void
update_obj(struct aoi_space *space, uint32_t id) {
	int i;
	for (i=0;i<3;i++) {
		OBJ[id].pos[i] += OBJ[id].v[i];
		if (OBJ[id].pos[i] < 0) {
			OBJ[id].pos[i]+=100.0f;
		} else if (OBJ[id].pos[i] > 100.0f) {
			OBJ[id].pos[i]-=100.0f;
		}
	}
	aoi_update(space, id, OBJ[id].mode, OBJ[id].pos);
}

static void
message(void *ud, uint32_t watcher, uint32_t marker) {
	printf("%u (%f,%f) => %u (%f,%f)\n",
		watcher, OBJ[watcher].pos[0], OBJ[watcher].pos[1],
		marker, OBJ[marker].pos[0], OBJ[marker].pos[1]
	);
	//if (instance != NULL) {
	//	call_back(instance->pHandle, true, watcher, marker);
	//}
	
}

static void _aoi_update2(struct aoi_space * space,int id, float x, float y) {

	float f3[3];
	f3[0] =x;
	f3[1] =y;
	f3[2] = 0;
	aoi_update(space, id, OBJ[id].mode, f3);
}
static void test(struct aoi_space * space) {
	init_obj(0, 2, 2, 0, 0, "wm");
	init_obj(1, 3, 3, 0, 0, "wm");
	_aoi_update2(space, 0, 6, 6);
	_aoi_update2(space, 1, 6, 6);
	aoi_message(space, message, NULL);
	_aoi_update2(space, 1, 6, 20);
	aoi_message(space, message, NULL);

}
static void
test2(struct aoi_space * space) {
	init_obj(0,40,0,0,1,"w");
	init_obj(1,42,100,0,-1,"wm");
	init_obj(2,0,40,1,0,"w");
	init_obj(3,100,45,-1,0,"wm");
	
	int i,j;
	for (i=0;i<100;i++) {
		if (i<50) {
			for (j=0;j<4;j++) {
				update_obj(space,j);
			}
		} else if (i==50) {
			aoi_update(space, 3, "d", OBJ[3].pos);
		} else {
			for (j=0;j<3;j++) {
				update_obj(space,j);
			}
		}
		aoi_message(space, message, NULL);
	}
}



static void call_back(void* _pAoi,bool flag,int watcher,int marker)
{

	//aoi_tt* pAoi = (aoi_tt*)_pAoi;
	lua_rawgeti(instance->pLuaState, LUA_REGISTRYINDEX, instance->iRef);
	lua_pushinteger(instance->pLuaState, flag);
	lua_pushinteger(instance->pLuaState, watcher);
	lua_pushinteger(instance->pLuaState, marker);
	lua_pcall(instance->pLuaState,3,0, 0);
}
static int aoi_setCallback(lua_State *L){


	instance->pLuaState = L;
	luaL_checktype(L,1,LUA_TFUNCTION);
	lua_settop(L,1);

	

	instance->iRef = luaL_ref(L,LUA_REGISTRYINDEX);
	
	lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
	return 0;
}

static int _aoi_update(lua_State *L){
	
	int id = luaL_checkinteger(L,1);
	
	float x = luaL_checknumber(L,2);
	float y = luaL_checknumber(L,3);

	OBJ[id].pos[0] = x;
	OBJ[id].pos[1] = y;
	OBJ[id].pos[2] = 0;
	
	//aoi_update(instance->pHandle, id, OBJ[id].mode, OBJ[id].pos);
	_aoi_update2(instance->pHandle, id, x, y);
	return 0;
}

static int _frame(lua_State *L){

	aoi_message(instance->pHandle, message, NULL);

	return 0;
}
static int aoi_addObj(lua_State *L){

	// aoi_tt* pAoi = (aoi_tt*)luaL_checkudata(L, 1, "aoiSpace");


	float x = luaL_checknumber(L,1);
	float y = luaL_checknumber(L,2);
	const char * type = luaL_checkstring(L,3); 
	init_obj(counter,x,y,0,0,type);
	counter++;
	lua_pushinteger(L,counter - 1);

	
	// init_obj(1,42,100,0,-1,"wm");
	// init_obj(2,0,40,1,0,"w");
	// init_obj(3,100,45,-1,0,"wm");
	return 1;
}

static int createSpace(lua_State *L) {


	instance = new aoi_tt();
	
	instance->iRef = -1;
	instance->pLuaState = NULL;
	struct alloc_cookie cookie = { 0,0,0 };
	instance->pHandle = aoi_create(my_alloc, &cookie);
	return 1;
}
int32_t registerSpace(struct lua_State *L){

	//luaL_newmetatable(L, "aoiSpace");
	//lua_pushvalue(L, -1);
	//lua_setfield(L, -2, "__index");
	
	struct luaL_Reg lua_towerSpaceFuncs[] = 
	{
		{"setCallback",		aoi_setCallback},
		{"add",			aoi_addObj},
		{"update",			_aoi_update},
		{"frame",			_frame},
		{"createSpace", createSpace},
		{NULL, NULL}
	};

	luaL_setfuncs(L, lua_towerSpaceFuncs, 0);
	return 1;

}


static luaL_Reg luaLibs[] =
{
	{"setCallback",		aoi_setCallback},
	{"add",			aoi_addObj},
	{"update",			_aoi_update},
	{"frame",			_frame},
	{"createSpace", createSpace},
	{NULL, NULL}
};
extern "C"  __declspec(dllexport) int luaopen_Aoi(lua_State *L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
int
main() {
	struct alloc_cookie cookie = { 0,0,0 };
	struct aoi_space * space = aoi_create(my_alloc, &cookie);
	_space = aoi_create(my_alloc, &cookie);
	//instance = (aoi_tt*)malloc(sizeof(aoi_tt));
	instance = new aoi_tt();
	instance->pHandle = aoi_create(my_alloc, &cookie);
	test(instance->pHandle);
	
	aoi_release(instance->pHandle);
	
	return 0;
}