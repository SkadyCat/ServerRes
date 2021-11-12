
#include "Aoi.h"
#include <stdlib.h>
#include <math.h>

Aoi::Aoi(float x,float z,AoiContext* context)
{

	m_context = context;
	m_speed = 1;
	m_radius = 5;
	m_ref = 0;
	m_pos.m_x = x;
	m_pos.m_z = z;

}

Aoi::Aoi(float x, float z, float speed, AoiContext* context) :m_pos(x, z) {
	m_context = context;
	m_speed = speed;
	m_radius = 5;
	m_ref = 0;
	m_id = context->m_countor++;
	m_pos.m_x = x;
	m_pos.m_z = z;


	//cout << "´´½¨½ÇÉ«" << endl;
}

string Aoi::info()
{
	ostringstream oss;

	oss << "id:" << m_id << endl;
	oss << "pos:(" <<  m_pos.m_x << "," << m_pos.m_z << ")" << endl;
	oss << "view:(";
	std::map<int, int>::iterator it = keys.begin();

	while (it != keys.end()) {

		oss << it->first << ",";
		it++;
	}
	string temp = oss.str();
	temp = temp.substr(0, temp.length() - 1);
	temp += ")\n";
	return temp;
}
Aoi::~Aoi() {
}

void Aoi::RandomTarget() {
	this->SetTarget(rand() % (int)m_context->m_width, rand() % (int)m_context->m_height);
}

void Aoi::SetTarget(float x, float z) {
	m_target.m_x = x;
	m_target.m_z = z;
}

void Aoi::Update(float interval) {
	
	float dt = m_pos.Distance(m_target);
	if (dt <= 5) {
		RandomTarget();
	} else {
		float dt = m_speed * interval;
		m_pos.MoveForward(m_target, dt);
	}
}

void Aoi::Draw() {
}

void Aoi::Ref(int aim) {
	m_ref++;
	//keys[aim] = 2;
}

void Aoi::DeRef(int aim) {
	m_ref--;
	//keys.erase(aim);
}

void Aoi::setPos(float x, float z)
{
	m_pos.m_x = x;
	m_pos.m_z = z;
}

void Aoi::refresh()
{


}
