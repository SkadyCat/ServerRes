#include <unordered_map>

#include "../Help/help.h"
#include<queue>
using namespace std;
extern "C"
{
#include "lua.h"  
#include "lualib.h"  
#include "lauxlib.h"  
}


struct buffer {
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



static int _new(lua_State* L){
	buffer* buf = new buffer();
	buf->getLen = true;
	buf->isRest = false;
	lua_pushlightuserdata(L, buf);
	return 1;
}
static //c++ byteתint
 
int bytesToInt(char bytes[4])
{
	int a = bytes[0] & 0xFF;
	a |= ((bytes[1] << 8) & 0xFF00);
	a |= ((bytes[2] << 16) & 0xFF0000);
	a |= ((bytes[3] << 24) & 0xFF000000);
	return a;
}
static int read(lua_State* L) {
	buffer* bf = (buffer*)lua_touserdata(L, 1);
	const char* buf = luaL_checkstring(L, 2);
	queue<char>& mq = bf->mq;
	int len = luaL_checkinteger(L, 3);
	for (int i = 0; i < len; i++) {
		bf->mq.push(buf[i]);
	}
	vector<int> tempBuffer;
	while (bf->mq.size() > 0) {
		if (bf->getLen == true) {
			if (bf->mq.size()>4) {
				if (bf->isRest) {
					for (int i = bf->lenCounter; i < 4; i++) {
						bf->len[i] = mq.front();
						mq.pop();
						
					}
					bf->lenCounter = 0;
					bf->theAimLen = bytesToInt(bf->len);
					bf->isRest = false;
				}
				else {
					bf->len[0] = mq.front();
					mq.pop();
					bf->len[1] = mq.front();
					mq.pop();
					bf->len[2] = mq.front();
					mq.pop();
					bf->len[3] = mq.front();
					mq.pop();
					bf->theAimLen = bytesToInt(bf->len);
				}
				bf->getLen = false;
			}
			else {
				bf->getLen = true;
				
			}
			
		}
		if(mq.size()< bf->theAimLen){
			break;
		}
		while (mq.size() != 0) {
			if (tempBuffer.size() == bf->theAimLen) {
				break;
			}
			tempBuffer.push_back(mq.front());
			mq.pop();
		}
	    // cout<<"buflen = "<<tempBuffer.size()<<" "<<bf->theAimLen<<"rest = "<<mq.size()<<endl;
		if (tempBuffer.size() == bf->theAimLen) {
			string val = "";
			for(int i =0;i<tempBuffer.size();i++){
				val+= (char)tempBuffer[i];
			}
			bf->sbuff.push_back(val);
			bf->buffers.push_back(tempBuffer);
			tempBuffer.clear();
			bf->aimBuffer.clear();
			bf->theAimLen = 0;
			bf->getLen = true;
			bf->isRest = false;
			bf->buffCounter = 0;
			bf->lenCounter = 0;
			bf->len[0] = 0;
			bf->len[1] = 0;
			bf->len[2] = 0;
			bf->len[3] = 0;	
			bf->tempBuff.clear();
		}

		if(mq.size()<4){
			bf->isRest = true;
			while (mq.size() != 0)
			{
				bf->len[bf->lenCounter] = mq.front();
				mq.pop();
				bf->lenCounter++;
			}			
		}
	}
	int size = bf->buffers.size();
	addArray(L,bf->sbuff);
	bf->sbuff.clear();
	bf->buffers.clear();
	return 1;
}
static int _delete(lua_State* L) {

	return 0;
}



static luaL_Reg luaLibs[] =
{
	{"new", _new},
	{"read",read},
	{"delete",_delete},
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
