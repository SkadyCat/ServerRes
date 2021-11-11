

#include "Scene.h"
std::map<string, Scene*> Scene::maps;
Scene::Scene()
{
}
Scene* Scene::instance;
Scene::Scene(string path) {
	

	printf(path.c_str());
	//bool flag = geo.load(&context, path);

	//if (!flag) {
	//	
	//	printf("load null");
	//}

	
	sp.setContext(&context);
	//sp.handleMeshChanged(&geo);
	sp.load(path);
	//sp.handleBuild();
	//float begin[3] = { 1.67,-2.36,-5.7 };
	//float end[3] = { 22.4,-2.36,14.9 };
	//

}

vector<Vector3> Scene::findPath(Vector3& v1, Vector3& v2)
{

	float begin[3];
	float end[3];
	begin[0] = v1.x;
	begin[1] = v1.y;
	begin[2] = v1.z;
	end[0] = v2.x;
	end[1] = v2.y;
	end[2] = v2.z;
	return findPath(begin, end);
}

vector<Vector3> Scene::findPath(float begin[3], float end[3])
{
	vector<Vector3> tp;
	
	sp.findPath(begin, end);

	for (int i = 0; i < sp.m_nsmoothPath; i++)
	{
		Vector3 v3(-sp.m_smoothPath[i * 3], sp.m_smoothPath[i * 3+1], sp.m_smoothPath[i * 3 + 2]);
		tp.push_back(v3);
	}
	return tp;
}

Vector3::Vector3(float x, float y, float z)
{
	this->x = x;
	this->y = y;
	this->z = z;
}
