#pragma once


#include <vector>
extern "C" {
#include "tower/tower-aoi.h"
}

#include <map>
#include <unordered_map>

extern "C"
{
#include "../Lua/lua.h"  
#include "../Lua/lualib.h"  
#include "../Lua/lauxlib.h"  
}

class Aoi;

class AoiContext {
public:
	AoiContext(float width, float height, float range);
	~AoiContext();
	lua_State* lua;
	int entityRef;
	int triggerRef;

	int entityIndex;
	int triggerIndex;
	void entityRecall(int code,int type, int self, int other);
	void triggerRecall(int type, int self, int other);

	static void OnEntityRemove(int self, int other, void* ud);
	static void OnEntityEnter(int self, int other, void* ud);

	static void OnEntityLeave(int self, int other, void* ud);

	static void OnTriggerEnter(int self, int other, void* ud);

	static void OnTriggerLeave(int self, int other, void* ud);

	Aoi* CreateTriggerMarker(int id,float x,float z,float range);
	Aoi* CreateEntity(float x,float z);

	Aoi* getPlayer(int id) {
		
		return wm_list[id];
	}
	Aoi* CreateTrigger(float x, float z, float range);

	void RefEntity(int uid,int aim);

	void DeRefEntity(int uid,int aim);

	void Update(float interval);

	void remove(int id);

	void setPos(int id, float x, float z);

	std::vector<int> range(int id);
	void Draw();
public:
	float m_width;
	float m_height;
	float m_range;
	int m_countor;
	struct aoi* m_context;
	std::map<int, int> m_entity_status;
	std::map<int, Aoi*> m_entity_list;
	std::map<int, Aoi*> m_trigger_list;
	std::map<int, Aoi*> wm_list;
	std::unordered_map<int,int> idMaps;
	std::map<int, std::map<int, int>> links;
	std::unordered_map<int,int> userMap;

	std::vector<std::vector<int>> vecList;
};

