# afifo_ic_env
测试通过，注意是对wbin(wr_ptr_nxt)去判断写满/读空

写满的条件是高两位相反，剩余相同！
wr_full <=  (wr_ptr_nxt_g[AFIFO_MORE]^rd_ptr_2d[AFIFO_MORE]) && 
            (wr_ptr_nxt_g[AFIFO_MORE-1]^rd_ptr_2d[AFIFO_MORE-1]) &&
            (wr_ptr_nxt_g[AFIFO_MORE-2:0] == rd_ptr_2d[AFIFO_MORE-2:0]);
rd_empty <= wr_ptr_2d[AFIFO_MORE:0] == rd_ptr_nxt_g[AFIFO_MORE:0];
