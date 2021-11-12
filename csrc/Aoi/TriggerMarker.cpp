#include "TriggerMarker.h"
#include <math.h>
#include <sstream>
#include <iostream>
#include <iomanip>
using namespace std;
TriggerMarker::TriggerMarker(int id,float x, float z, float speed,float range, AoiContext* context)
	:Aoi(x,z,context)
{


	
	m_id = id;
	
	this->context = context;
	
	entity = context->CreateEntity(x,z);

	printf("create tm %d \n", id);
	trigger = context->CreateTrigger(x,z,range);
	

	context->idMaps[trigger->m_id] = id;
	context->idMaps[entity->m_id] = id;
	//context->idMaps.insert({ trigger->m_id ,m_id });
	//context->idMaps.insert({ entity->m_id ,m_id });

	
	m_target.setData((rand() % (int)m_context->m_width), (rand() % (int)m_context->m_height));
}

TriggerMarker::~TriggerMarker()
{
	
}

void TriggerMarker::SetTarget(float x, float z) {
	entity->SetTarget(x,z);
	trigger->SetTarget(x, z);
}
void TriggerMarker::Enter()
{
	entity->Enter();
	trigger->Enter();
}
int times = 0;
void TriggerMarker::Update(float interval)
{

	
	maps.clear();
	if (times > 100) {
		m_target.setData((rand() % (int)m_context->m_width), (rand() % (int)m_context->m_height));
		times = 0;
	}
	times++;
	Aoi::Update(0.5);
	entity->m_pos = m_pos;
	trigger->m_pos = m_pos;
	entity->Update(interval);
	trigger->Update(interval);
	
	




	

}
void setPos() {

	
}
void TriggerMarker::Draw()
{
	trigger->Draw();
	entity->Draw();
	map<int, int>::iterator it = entity->keys.begin();

	while (it!= entity->keys.end())
	{
		Aoi* tt = context->wm_list[context->idMaps[it->first]];
		printf("\n key == %d\n", tt->m_id);
		keys[tt->m_id] = 2;
		it++;
	}
	it = trigger->keys.begin();
	while (it != trigger->keys.end())
	{
		Aoi* tt = context->wm_list[context->idMaps[it->first]];

		printf("\n key == %d\n", tt->m_id);
		keys[tt->m_id] = 2;
		it++;
	}
	
}

void TriggerMarker::setPos(float x, float z)
{

	m_pos.m_x = x;
	m_pos.m_z = z;
	entity->m_pos = m_pos;
	trigger->m_pos = m_pos;
	
	refresh();
}

void TriggerMarker::refresh()
{
	keys.clear();
	entity->refresh();
	trigger->refresh();
	map<int, int>::iterator it = entity->keys.begin();
	while (it != entity->keys.end())
	{

		//cout << it->first << "endl";
		//cout << context->idMaps[it->first] << "endl";
		//Aoi* tt = context->wm_list[context->idMaps[it->first]];
		//keys[it->first] = 2;

		//cout << context->idMaps[it->first] << "&&&" << it->first << endl;
		if (context->idMaps[it->first] == 0) {
			context->idMaps.erase(it->first);
		}
		else
		{
			keys[context->idMaps[it->first]] = 2;
		}
	

		it++;


	}
	it = trigger->keys.begin();
	while (it != trigger->keys.end())
	{

		/*cout<< it->first <<"endl";
		cout << context->idMaps[it->first] << "endl";*/
		/*Aoi* tt = context->wm_list[context->idMaps[it->first]];*/
		if (context->idMaps[it->first] == 0) {
			context->idMaps.erase(it->first);
		}
		else
		{
			keys[context->idMaps[it->first]] = 2;
		}
		
		it++;
	}

}

string TriggerMarker::info()
{

	string val = Aoi::info();

	ostringstream oss;

	AoiTrigger* tr = (AoiTrigger*)trigger;
	oss << "range:" << tr->m_range << endl;

	return val + oss.str();

}
