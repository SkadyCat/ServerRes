#pragma once

#include "Vector2.h"
#include "AoiContext.h"
#include <vector>
#include <string>
#include <sstream>
#include <iomanip>
using namespace std;
class Aoi {
public:

	Aoi(float x, float z, AoiContext* context);
	Aoi(float x, float z, float speed, AoiContext* context);
	~Aoi();
	int removeID;
	void RandomTarget();

	void SetTarget(float x, float z);

	virtual void Enter() = 0;

	virtual void Update(float interval);

	virtual void Draw();

	virtual void Ref(int aim);
	virtual void DeRef(int aim);
	virtual void setPos(float x, float z);
	virtual void refresh();
	virtual string info();
public:
	float m_radius;
	float m_speed;
	int m_id;
	int m_ref;
	AoiContext* m_context;
	Vector2 m_pos;
	Vector2 m_target;
	std::map<int,int> keys;

	std::map<int, int> entities;
	std::map<int, int> triggers;

};

