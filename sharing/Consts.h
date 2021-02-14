//
//  Consts.h
//  sharing
//
//  Created by Ninan Thomas on 2/1/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#ifndef Consts_h
#define Consts_h

#define BUFFER_BOUND 800
#define RCV_BUF_LEN 16384
#define MSG_AGGR_BUF_LEN 32768

 #define MAX_BUF 16384

#define GET_SHARE_ID_MSG 1
#define GET_SHARE_ID_RPLY_MSG 2
#define STORE_TRNSCTN_ID_MSG  3
#define STORE_TRNSCTN_ID_RPLY_MSG  4
#define STORE_FRIEND_LIST_MSG 5
#define STORE_FRIEND_LIST_RPLY_MSG 6
#define ARCHIVE_ITEM_MSG 7
#define ARCHIVE_ITEM_RPLY_MSG 8
#define SHARE_ITEM_MSG 9
#define SHARE_ITEM_RPLY_MSG 10
#define STORE_DEVICE_TKN_MSG 11
#define STORE_DEVICE_TKN_RPLY_MSG 12
#define GET_ITEMS 13
#define GET_ITEMS_RPLY_MSG 14
#define PIC_METADATA_MSG 15
#define PIC_METADATA_RPLY_MSG 16
#define PIC_MSG 17
#define PIC_RPLY_MSG 18
#define SHARE_TEMPL_ITEM_MSG 22
#define SHARE_TEMPL_ITEM_RPLY_MSG 23
#define PIC_DONE_MSG 19
#define SHOULD_UPLOAD_MSG 20
#define SHOULD_DOWNLOAD_MSG 21

#define TOTAL_PIC_LEN_MSG 1500
#define UPDATE_MAX_SHARE_ID_MSG 1501
#define SHARE_ID_REMOTE_HOST_MSG 1502
#define GET_REMOTE_HOST_MSG 1503
#define MAX_IDLE_TIME 15


#endif /* Consts_h */
