#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern "C"
{

	#include "aoi.h"
}
struct alloc_cookie {
	int count;
	int max;
	int current;
};

static void *
my_alloc(void * ud, void *ptr, size_t sz) {
	struct alloc_cookie * cookie = (alloc_cookie *)ud;
	if (ptr == NULL) {
		void *p = malloc(sz);
		++cookie->count;
		cookie->current += sz;
		if (cookie->max < cookie->current) {
			cookie->max = cookie->current;
		}
		//		printf("%p + %u\n",p, sz);
		return p;
	}
	--cookie->count;
	cookie->current -= sz;
	//	printf("%p - %u \n",ptr, sz);
	free(ptr);
	return NULL;
}

struct OBJECT {
	float pos[3];
	float v[3];
	char mode[4];
};

static struct OBJECT OBJ[4];

static void
init_obj(uint32_t id, float x, float y, float vx, float vy, const char *mode) {
	OBJ[id].pos[0] = x;
	OBJ[id].pos[1] = y;
	OBJ[id].pos[2] = 0;

	OBJ[id].v[0] = vx;
	OBJ[id].v[1] = vy;
	OBJ[id].v[2] = 0;

	strcpy(OBJ[id].mode, mode);
}

static void
update_obj(struct aoi_space *space, uint32_t id) {
	int i;
	for (i = 0; i < 3; i++) {
		OBJ[id].pos[i] += OBJ[id].v[i];
		if (OBJ[id].pos[i] < 0) {
			OBJ[id].pos[i] += 100.0f;
		}
		else if (OBJ[id].pos[i] > 100.0f) {
			OBJ[id].pos[i] -= 100.0f;
		}
	}
	aoi_update(space, id, OBJ[id].mode, OBJ[id].pos);
}

static void
message(void *ud, uint32_t watcher, uint32_t marker,int flag) {

	if (flag == 0) {
		printf("%u leave (%f,%f) => %u (%f,%f)\n",
			watcher, OBJ[watcher].pos[0], OBJ[watcher].pos[1],
			marker, OBJ[marker].pos[0], OBJ[marker].pos[1]
		);
	}
	else {
		printf("%u enter (%f,%f) => %u (%f,%f)\n",
			watcher, OBJ[watcher].pos[0], OBJ[watcher].pos[1],
			marker, OBJ[marker].pos[0], OBJ[marker].pos[1]
		);

	}
	
}

static void setPos(struct aoi_space * space,int id, float x, float y) {
	OBJ[id].pos[0] = x;
	OBJ[id].pos[1] = y;
	aoi_update(space, id, OBJ[id].mode, OBJ[id].pos);
	aoi_message(space, message, NULL);

}
static void
test(struct aoi_space * space) {
	init_obj(0, 0, 0, 0, 1, "w");
	init_obj(1, 0, 0, 0, -1, "m");
	//init_obj(2, 0, 40, 1, 0, "w");
	//init_obj(3, 100, 45, -1, 0, "wm");
	setPos(space,0, 0, 0);
	setPos(space,1, 0, 0);
	setPos(space, 0, 9, 0);
	setPos(space, 0, 10.1, 0);

	//setPos(space, 0, 5.1,5);
	setPos(space, 0, 0, 0);

	setPos(space, 0, 10.1, 0);
}

int
main() {
	struct alloc_cookie cookie = { 0,0,0 };
	struct aoi_space * space = aoi_create(my_alloc, &cookie);

	test(space);

	aoi_release(space);
	printf("max memory = %d, current memory = %d\n", cookie.max, cookie.current);
	return 0;
}

