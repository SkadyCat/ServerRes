#include <unordered_map>
#include "help.h"
#include <queue>
#include <deque>
#include <stack>
using namespace std;
extern "C"
{
	#include "lua.h"  
	#include "lualib.h"  
	#include "lauxlib.h"  
}

int bytes2Int(vector<char> vv)
{

	int v = 0;
	int len = vv[0];
	if (len >= 4) {
		len = len - 4;
	}
	for (int i = 0; i < len + 1; i++) {
		unsigned char t = (unsigned char)vv[i + 1];
		v = v | (t << 8 * i);
	}
	if (vv[0] >= 4) {
		return -v;
	}
	return v;
}


vector<char> int2Bytes(int v)
{
	int flag = v;

	vector<char> aim;
	v = abs(v);
	vector<char> chars(4);
	chars[3] = (char)(v >> 24);
	chars[2] = (char)(v >> 16);
	chars[1] = (char)(v >> 8);
	chars[0] = (char)v;
	if (v < 256)
	{
		if (flag < 0) {
			aim.push_back(0x04);
		}
		else {
			aim.push_back(0x00);
		}
	}
	if (v >= 256 && v < 65536)
	{
		if (flag < 0) {
			aim.push_back(0x05);
		}
		else {
			aim.push_back(0x01);
		}
	}
	if (v >= 65536 && v < (256 * 256 * 256))
	{
		if (flag < 0) {
			aim.push_back(0x06);
		}
		else {
			aim.push_back(0x02);
		}
	}
	if (v >= (256 * 256 * 256))
	{
		if (flag < 0) {
			aim.push_back(0x07);
		}
		else {
			aim.push_back(0x03);
		}
	}


	switch (aim[0])
	{
	case 0x00:
		aim.push_back(chars[0]);
		break;

	case 0x01:
		aim.push_back(chars[0]);
		aim.push_back(chars[1]);
		break;

	case 0x02:
		aim.push_back(chars[0]);
		aim.push_back(chars[1]);
		aim.push_back(chars[2]);
		break;

	case 0x03:
		aim.push_back(chars[0]);
		aim.push_back(chars[1]);
		aim.push_back(chars[2]);
		aim.push_back(chars[3]);
		break;
	case 0x04:
		aim.push_back(chars[0]);
		break;

	case 0x05:
		aim.push_back(chars[0]);
		aim.push_back(chars[1]);
		break;

	case 0x06:
		aim.push_back(chars[0]);
		aim.push_back(chars[1]);
		aim.push_back(chars[2]);
		break;

	case 0x07:
		aim.push_back(chars[0]);
		aim.push_back(chars[1]);
		aim.push_back(chars[2]);
		aim.push_back(chars[3]);
		break;

	}
	return aim;
}


struct buffer {

	deque<char> dq;

	queue<char> mq;
	int lenCounter;
	char len[4];
	vector<int> aimBuffer;
	bool getLen;
	bool isRest;
	int theAimLen;
	int buffCounter;

	int groupCount;
	vector<vector<int>> buffers;
	vector<string> sbuff;
	vector<int> tempBuff;

};
//unordered_map<string,>



static int New(lua_State* L){
	buffer* buf = new buffer();
	buf->getLen = true;
	buf->isRest = false;
	lua_pushlightuserdata(L, buf);
	return 1;
}

/*
接收参数：
	pos0: buffer对象
	pos1: 接收的bytes
	pos2: 接收的byte的长度
返回参数：
	无
*/

static int log(lua_State * L) {
	buffer* bf = (buffer*)lua_touserdata(L, 1);
	const char* buf = luaL_checkstring(L, 2);
	int len = luaL_checkinteger(L, 3);
	cout << "logByte:";
	for (int i = 0; i < len; i++) {
		cout << (int)buf[i] << ",";
	}
	cout << endl;
	return 0;
}
static void logByte(vector<char> data) {
	cout << "logByte:";
	for (auto k : data) {
		cout << (int)k << ",";
	}
	cout << endl;
}
static int Read(lua_State * L) {
	buffer* bf = (buffer*)lua_touserdata(L, 1);
	const char* buf = luaL_checkstring(L, 2);
	int len = luaL_checkinteger(L, 3);
	cout << len << endl;
	for (int i = 0; i < len; i++) {
		bf->dq.push_front(buf[i]);
	}
	for (int i = 0; i < len; i++) {
		cout << (int)buf[i] << ",";
	}
	cout << endl;
	return 0;
}

/*
	
接收参数：
	pos0：buffer对象
返回参数：
	pos0: 协议的名称
	
*/

static int GetString(lua_State * L) {
	buffer* bf = (buffer*)lua_touserdata(L, 1);
	stack<char> stk;
	int len = bf->dq.back() + 1;

	if (len > bf->dq.size()) {
		//its point that there no enough data in the buffer
		return 0;
	}

	vector<char> lenBytes(len+1);
	for (int i = 0; i < lenBytes.size(); i++)
	{
		lenBytes[i] = bf->dq.back();
		stk.push(bf->dq.back());
		cout << bf->dq.back() << endl;

		bf->dq.pop_back();
	}
	logByte(lenBytes);
	int dataLen = bytes2Int(lenBytes);
	if (dataLen > bf->dq.size()) {
		//需要回档
		//回档就是将4,3,2,1塞入back
		while (stk.size()!= 0) {
			bf->dq.push_back(stk.top());
			stk.pop();
		}
		return 0;
	}
	vector<char> dataBytes(dataLen);
	for (int i = 0; i < dataBytes.size(); i++) {
		dataBytes[i] = bf->dq.back();
		bf->dq.pop_back();
	}
	string protoName;
	protoName.assign(dataBytes.begin(), dataBytes.end());
	cout << "--"<<dataLen << endl;
	logByte(dataBytes);
	lua_pushstring(L, protoName.c_str());
	return 1;
}

static int GetMsg(lua_State * L) {
	buffer* bf = (buffer*)lua_touserdata(L, 1);
	stack<char> stk;
	int len = bf->dq.back() + 1;

	if (len > bf->dq.size()) {
		//its point that there no enough data in the buffer
		return 0;
	}
	vector<char> lenBytes(len + 1);
	for (int i = 0; i < lenBytes.size(); i++)
	{
		lenBytes[i] = bf->dq.back();
		stk.push(bf->dq.back());
		bf->dq.pop_back();
	}
	int dataLen = bytes2Int(lenBytes);
	if (dataLen > bf->dq.size()) {
		//需要回档
		//回档就是将4,3,2,1塞入back
		while (stk.size() != 0) {
			bf->dq.push_back(stk.top());
			stk.pop();
		}
		return 0;
	}
	vector<int> dataBytes(dataLen);
	for (int i = 0; i < dataBytes.size(); i++) {
		dataBytes[i] = bf->dq.back();
		bf->dq.pop_back();
	}
	string v = "";
	for (auto k : dataBytes) {
		v += (char)k;
	}
	lua_pushstring(L, v.c_str());
	return 1;
}

//static int read(lua_State* L) {
//	buffer* bf = (buffer*)lua_touserdata(L, 1);
//	const char* buf = luaL_checkstring(L, 2);
//	queue<char>& mq = bf->mq;
//	int len = luaL_checkinteger(L, 3);
//	for (int i = 0; i < len; i++) {
//		bf->mq.push(buf[i]);
//	}
//	vector<int> tempBuffer;
//	while (bf->mq.size() > 0) {
//		if (bf->getLen == true) {
//			if (bf->mq.size()>4) {
//				if (bf->isRest) {
//					for (int i = bf->lenCounter; i < 4; i++) {
//						bf->len[i] = mq.front();
//						mq.pop();
//						
//					}
//					bf->lenCounter = 0;
//					bf->theAimLen = bytesToInt(bf->len);
//					bf->isRest = false;
//				}
//				else {
//					bf->len[0] = mq.front();
//					mq.pop();
//					bf->len[1] = mq.front();
//					mq.pop();
//					bf->len[2] = mq.front();
//					mq.pop();
//					bf->len[3] = mq.front();
//					mq.pop();
//					bf->theAimLen = bytesToInt(bf->len);
//				}
//				bf->getLen = false;
//			}
//			else {
//				bf->getLen = true;
//				
//			}
//			
//		}
//		if(mq.size()< bf->theAimLen){
//			break;
//		}
//		while (mq.size() != 0) {
//			if (tempBuffer.size() == bf->theAimLen) {
//				break;
//			}
//			tempBuffer.push_back(mq.front());
//			mq.pop();
//		}
//	    // cout<<"buflen = "<<tempBuffer.size()<<" "<<bf->theAimLen<<"rest = "<<mq.size()<<endl;
//		if (tempBuffer.size() == bf->theAimLen) {
//			string val = "";
//			for(int i =0;i<tempBuffer.size();i++){
//				val+= (char)tempBuffer[i];
//			}
//			bf->sbuff.push_back(val);
//			bf->buffers.push_back(tempBuffer);
//			tempBuffer.clear();
//			bf->aimBuffer.clear();
//			bf->theAimLen = 0;
//			bf->getLen = true;
//			bf->isRest = false;
//			bf->buffCounter = 0;
//			bf->lenCounter = 0;
//			bf->len[0] = 0;
//			bf->len[1] = 0;
//			bf->len[2] = 0;
//			bf->len[3] = 0;	
//			bf->tempBuff.clear();
//		}
//
//		if(mq.size()<4){
//			bf->isRest = true;
//			while (mq.size() != 0)
//			{
//				bf->len[bf->lenCounter] = mq.front();
//				mq.pop();
//				bf->lenCounter++;
//			}			
//		}
//	}
//	int size = bf->buffers.size();
//	addArray(L,bf->sbuff);
//	bf->sbuff.clear();
//	bf->buffers.clear();
//	return 1;
//}
static int _delete(lua_State* L) {

	return 0;
}



static luaL_Reg luaLibs[] =
{
	{"new", New},
	{"read",Read},
	{"delete",_delete},
	{"getString",GetString},
	{"getMsg",GetMsg},
	{"log",log},
	{ NULL, NULL }
};


#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
extern "C"  __declspec(dllexport) int luaopen_BufferReader(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
#ifdef _WIN64
	
#endif

#if __linux__
extern "C"  int luaopen_BufferReader(lua_State * L)
{
	lua_newtable(L);
	luaL_setfuncs(L, luaLibs, 0);
	return 1;
}
#endif
