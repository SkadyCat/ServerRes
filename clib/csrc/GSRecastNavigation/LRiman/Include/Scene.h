
#pragma once
#include <iostream>
#include "Context.h"
#include "InputGeom.h"
#include "Sample_SoloMesh.h"
#include <string>
#include <map>

#include <vector>



using namespace std;

struct Vector3 {
public:
	Vector3(float x, float y, float z);
	float x;
	float y;
	float z;
};


class Scene {

public:
	static Scene* instance;
	static std::map<string, Scene*> maps;
	rcContext context;
	//context.enableLog(true);
	InputGeom geo;
	Sample_SoloMesh sp;
	Scene();
	Scene(string path);

	vector<Vector3> findPath(Vector3& v1,Vector3& v2);
	vector<Vector3> findPath(float begin[3], float end[3]);


};