
Ž	
	Bag.proto"E
BagCode
BAG_SUCCESS (R
BAGSUCCESS
BAG_FAIL (RBAGFAIL"j
BagGridInfo
item_id (RitemId
grid_id (RgridId
grid_num (RgridNum
cd (Rcd"'

BagPullReq
user_acc (	RuserAcc"{

BagPullRet
code (Rcode2
grid_info_list (2.BagGridInfoRgridInfoList%
open_timestamp (RopenTimestamp"[

BagDragReq
	origin_id (RoriginId
dst_id (RdstId
user_acc (	RuserAcc"f

BagDragRet
code (Rcode$
origin (2.BagGridInfoRorigin
dst (2.BagGridInfoRdst"2
BagPackUpReq
from (Rfrom
to (Rto"@
BagPackUpRet
code (Rcode
to (2.BagGridInfoRto"C
	BagUseReq
	origin_id (RoriginId
user_acc (	RuserAcc"E
	BagUseRet
code (Rcode$
origin (2.BagGridInfoRorigin"n
	BagAddReq
	origin_id (RoriginId
item_id (RitemId
num (Rnum
user_acc (	RuserAcc"E
	BagAddRet
code (Rcode$
origin (2.BagGridInfoRorigin"G
BagDiscardReq
	origin_id (RoriginId
user_acc (	RuserAcc"I
BagDiscardRet
code (Rcode$
origin (2.BagGridInfoRoriginBªMessage.Bagbproto3