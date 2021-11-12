
#include "AoiContext.h"
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "AoiEntity.h"
#include "AoiTrigger.h"
#include "TriggerMarker.h"
#include <sstream>
#include <iostream>
AoiContext::AoiContext(float width, float height, float range) {
	m_width = width;
	m_height = height;
	m_range = range;
	m_countor = 1;
	m_context = NULL;
	m_context = create_aoi(5000, width, height, 1);
}


AoiContext::~AoiContext() {
}

void AoiContext::entityRecall(int code,int type, int self, int other)
{

	vector<int> vec;
	vec.push_back(code);
	vec.push_back(type);
	vec.push_back(idMaps[self]);
	vec.push_back( idMaps[other]);
	vec.push_back(userMap[idMaps[self]]);
	vec.push_back(userMap[idMaps[other]]);

	vecList.push_back(vec);
	// lua_rawgeti(lua,  LUA_REGISTRYINDEX, LUA_RIDX_MAINTHREAD);
  	// lua_State *mL = lua_tothread(lua,-1);
  	// lua_pop(lua,1);
	// lua_rawgeti(lua, LUA_REGISTRYINDEX, entityRef);
	
	// lua_rawgeti(lua, LUA_REGISTRYINDEX,entityRef);
	// lua_pushinteger(lua, code);
	
	// lua_pushinteger(lua, type);
	
	// lua_pushinteger(lua, idMaps[self]);
	
	// lua_pushinteger(lua, idMaps[other]);
	
	// lua_pushinteger(lua,userMap[idMaps[self]]);
	
	// lua_pushinteger(lua,userMap[idMaps[other]]);
	
	// lua_call(lua, 6, 0);
	
}

void AoiContext::triggerRecall(int type, int self, int other)
{

	std::cout<<"trigger1: "<<triggerRef<<endl;
	lua_rawgeti(lua, triggerIndex, triggerRef);
	std::cout<<"trigger2: "<<triggerRef<<endl;
	lua_pushinteger(lua, type);
	std::cout<<"trigger3: "<<triggerRef<<endl;
	lua_pushinteger(lua, idMaps[self]);
	std::cout<<"trigger4: "<<triggerRef<<endl;
	lua_pushinteger(lua, idMaps[other]);
	std::cout<<"trigger5: "<<triggerRef<<endl;
	lua_pushinteger(lua,userMap[idMaps[self]]);
	std::cout<<"trigger6: "<<triggerRef<<endl;
	lua_pushinteger(lua,userMap[idMaps[other]]);
	std::cout<<"trigger7: "<<triggerRef<<endl;
	// lua_call(lua, 5, 0);
}

Aoi* AoiContext::CreateTrigger(float x, float z, float range) {

	//printf("input range %f\n", range);
	Aoi* aoi = new AoiTrigger(x, z, 1, range, this);
	aoi->RandomTarget();
	m_trigger_list[aoi->m_id] = aoi;
	

	return aoi;
}

Aoi* AoiContext::CreateEntity(float x,float z) {

	
	Aoi* aoi = new AoiEntity(x, z, 1, this);
	aoi->RandomTarget();
	m_entity_list[aoi->m_id] = aoi;
	
	
	return aoi;
}

Aoi* AoiContext::CreateTriggerMarker(int id, float x, float z, float range) {
	Aoi* aoi = new TriggerMarker(id,x, z,  10, range, this);
	aoi->RandomTarget();
	wm_list[aoi->m_id] = aoi;

	aoi->Enter();
	
	return aoi;
}


void AoiContext::OnEntityRemove(int self, int other, void * ud)
{
	AoiContext* inst = (AoiContext*)ud;
	// cout << inst->idMaps[self] <<"-------------------"<< inst->idMaps[other] << endl;
	if (inst->idMaps[self] != inst->idMaps[other]) {
		
		TriggerMarker * tm = (TriggerMarker *)inst->getPlayer(inst->idMaps[other]);
		tm->entity->keys.erase(inst->idMaps[self]);
		tm->trigger->keys.erase(inst->idMaps[self]);

		

	}
}

void AoiContext::OnEntityEnter(int self, int other, void* ud) {
	AoiContext* inst = (AoiContext*)ud;
	
	// cout << inst->idMaps[other] << " enter-> " << inst->idMaps[self] << endl;
	if (inst->idMaps[self] != inst->idMaps[other]) {
		inst->RefEntity(self,other);
		
		int _self = inst->idMaps[self];
		int _other = inst->idMaps[other];
		//cout << _self << "--enter ee "<<inst->wm_list.size()<<" " << _other << endl;
		inst->links[_self][_other] = 2;


		
		Aoi* wm_self = inst->wm_list[_self];
		Aoi* wm_other = inst->wm_list[_other];
		// cout << wm_self->m_id << endl;
		// cout << wm_other->m_id << endl;
		//��(entity) -> ��(trigger) ������
		wm_self->triggers[_other] = 2;
		wm_other->entities[_self] = 2;
		inst->entityRecall(0,1, self, other);
		//cout << _self << "--enter ee " << _other << endl;
	}
	

	//TriggerMarker* tmSelf = (TriggerMarker*)inst->wm_list[inst->idMaps[self]];

	//tmSelf->maps[inst->idMaps[other]] = 2;
}

void AoiContext::OnEntityLeave(int self, int other, void* ud) {
	
	AoiContext* inst = (AoiContext*)ud;
	//  cout << inst->idMaps[other] << " leave-> " << inst->idMaps[self] << endl;
	if (inst->idMaps[self] != inst->idMaps[other]) {
		inst->DeRefEntity(self, other);

		int _self = inst->idMaps[self];
		int _other = inst->idMaps[other];
		inst->links[_self].erase(_other);


		Aoi* wm_self = inst->wm_list[_self];
		Aoi* wm_other = inst->wm_list[_other];

		wm_self->triggers.erase(_other);
		wm_other->entities.erase(_self);

		inst->entityRecall(0,0, self, other);
	}
	
	

	//TriggerMarker* tmSelf = (TriggerMarker*)inst->wm_list[inst->idMaps[self]];
	//	
	//tmSelf->maps[inst->idMaps[other]] = 0;

	
}

void AoiContext::OnTriggerEnter(int self, int other, void* ud) {
	AoiContext* inst = (AoiContext*)ud;

	//if()
	

	
	if (inst->idMaps[self] != inst->idMaps[other]) {
		
		

		int _self = inst->idMaps[self];
		int _other = inst->idMaps[other];
		//cout << _self << "--enter te " << _other<< endl;
		inst->links[_self][_other] = 2;
		inst->RefEntity(other, self);

		//inst->wm_list[_self]->keys[_other] = 2;

		//inst->wm_list[_self]->entities = 

		Aoi* wm_self = inst->wm_list[_self];
		Aoi* wm_other = inst->wm_list[_other];

		wm_self->entities[_other] = 2;
		wm_other->triggers[_self] = 2;
		inst->entityRecall(1,1, self, other);
		// inst->triggerRecall(1, self, other);
	}

}

void AoiContext::OnTriggerLeave(int self, int other, void* ud) {
	AoiContext* inst = (AoiContext*)ud;
	if (inst->idMaps[self] != inst->idMaps[other]) {
		int _self = inst->idMaps[self];
		int _other = inst->idMaps[other];
		inst->links[_self].erase(_other);
		inst->DeRefEntity(other, self);
		Aoi* wm_self = inst->wm_list[_self];
		Aoi* wm_other = inst->wm_list[_other];
		wm_self->entities.erase(_other);
		wm_other->triggers.erase(_self);
		inst->entityRecall(1,0, self, other);
	}
}

void AoiContext::RefEntity(int uid,int aim) {
	
	std::map<int, Aoi*>::iterator iter = m_entity_list.find(uid);
	if (iter != m_entity_list.end()) {
		Aoi* aoi = iter->second;
		//printf("links -> %d---%d\n", aoi->m_ref, aoi->keys.size());

		aoi->Ref(aim);
		
	} else {
		std::map<int, Aoi*>::iterator iter = m_trigger_list.find(uid);
		Aoi* aoi = iter->second;
		aoi->Ref(aim);
	}

}

void AoiContext::DeRefEntity(int uid,int aim) {
	std::map<int, Aoi*>::iterator iter = m_entity_list.find(uid);
	if (iter != m_entity_list.end()) {
		Aoi* aoi = iter->second;
		aoi->DeRef(aim);
	} else {
		std::map<int, Aoi*>::iterator iter = m_trigger_list.find(uid);
		Aoi* aoi = iter->second;
		aoi->DeRef(aim);
	}
}


void AoiContext::Update(float interval) {
	std::map<int, Aoi*>::iterator iter = wm_list.begin();
	for (; iter != wm_list.end(); iter++) {
		
		Aoi* aoi = iter->second;
		aoi->setPos(rand() % (int)500, rand() % (int)500);
		//aoi->refresh();
	}

}

void AoiContext::remove(int id)
{
	TriggerMarker* mt = (TriggerMarker*)wm_list[id];
	
	AoiEntity * ae = (AoiEntity *)mt->entity;
	AoiTrigger * at = (AoiTrigger *)mt->trigger;
	remove_entity(m_context, ae->m_entity,
	AoiContext::OnEntityRemove,this);

	remove_trigger(m_context, at->m_trigger);
	idMaps.erase(mt->entity->m_id);
	idMaps.erase(mt->trigger->m_id);
	wm_list.erase(id);
	m_entity_list.erase(mt->entity->m_id);
	m_trigger_list.erase(mt->trigger->m_id);


	//cout<<"now the "
}

void AoiContext::setPos(int id, float x, float z)
{


	wm_list[id]->setPos(x, z);
	//wm_list[id]->refresh();

	
}

vector<int> AoiContext::range(int id)
{
	vector<int> temp;


	
	Aoi* aoi = wm_list[id];

	std::map<int, int>::iterator it = aoi->entities.begin();

	while (it != aoi->entities.end()) {
		temp.push_back(it->first);
		it++;
	}
	return temp;
}

void AoiContext::Draw() {
	/*std::map<int, Aoi*>::iterator iter = m_entity_list.begin();
	for (; iter != m_entity_list.end(); iter++) {
		Aoi* aoi = iter->second;
		aoi->Draw();
	}

	iter = m_trigger_list.begin();
	for (; iter != m_trigger_list.end(); iter++) {
		Aoi* aoi = iter->second;
		aoi->Draw();
	}*/

	std::map<int, Aoi*>::iterator iter = wm_list.begin();
	for (; iter != wm_list.end(); iter++) {
		Aoi* aoi = iter->second;
		aoi->Draw();
	}
}