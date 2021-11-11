
#include <iostream>
#include "Context.h"
#include "InputGeom.h"
#include "Sample_SoloMesh.h"
#include "Scene.h"
#include <string>
using namespace std;
int main() {


	cout << "hello world" << endl;
	//rcContext context;
	////context.enableLog(true);
	//InputGeom geo;
	//
	std::string pa(R"(F:\UnityProj\NavMesh\navmesh.bin)");
	//
	//cout << pa<<endl;
	//
	Scene sc(pa);
	float begin[3] = { 1.36f, -0.89,-2.55 };
	float end[3] = { -4.12, -1.321063, 0.29 };
	vector<Vector3> vec= sc.findPath(begin, end);

	for (auto k : vec) {
		
		cout << k.x << "," << k.y << "," << k.z << endl;

	}
	/*Scene sc(pa)
	
	sp.findPath(begin, end);
	sp.save();*/

	//sp.m_navQuery->findPath();
	return 0;
}