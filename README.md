afifo_ic_env
项目说明

本工程实现并验证了一个 异步 FIFO（Asynchronous FIFO），支持独立写时钟 / 读时钟域，采用 Binary Pointer + Gray Code + 双触发器同步 的经典结构。

当前版本 RTL + 黑盒 TB 已验证通过。

设计要点（非常重要）
1. 判满 / 判空必须基于 next pointer

写满（wr_full）
必须基于 wr_ptr_nxt（下一拍将要写入的位置） 判断
❌ 不能用当前 wr_ptr

读空（rd_empty）
必须基于 rd_ptr_nxt（下一拍将要读的位置） 判断
❌ 不能用当前 rd_ptr

这是异步 FIFO 最容易写错、但也是是否可靠的分水岭。

写满条件（Gray Code）

FIFO 深度为 2^N，指针宽度为 N+1（最高位用于区分回绕）。

写满条件定义：

写指针 next 的 Gray Code
与 读指针同步 Gray Code
高两位相反，其余位完全相同

判满公式
wr_full <=  (wr_ptr_nxt_g[AFIFO_MORE]   ^ rd_ptr_2d[AFIFO_MORE])   &&
            (wr_ptr_nxt_g[AFIFO_MORE-1] ^ rd_ptr_2d[AFIFO_MORE-1]) &&
            (wr_ptr_nxt_g[AFIFO_MORE-2:0] == rd_ptr_2d[AFIFO_MORE-2:0]);

工程含义

高 2 位取反 → 环形 FIFO “刚好写追上读”

低位一致 → 地址重合

使用 Gray Code 比较，避免跨时钟亚稳风险

读空条件（Gray Code）

读空条件定义：

写指针（同步后）
等于 读指针 next 的 Gray Code

判空公式
rd_empty <= (wr_ptr_2d[AFIFO_MORE:0] == rd_ptr_nxt_g[AFIFO_MORE:0]);

验证说明

测试方式：黑盒测试（Black-box TB）

覆盖场景：

单次写 / 读

连续写至满

连续读至空

空 → 写 → 读

波形格式：FSDB

结论：
RTL 功能正确，判满 / 判空逻辑已通过验证

经验总结（建议保留）

异步 FIFO 90% 的 Bug 都出在判满 / 判空

一定用 *_ptr_nxt

一定在 Gray Code 域比较

满：高两位反，其余相同

空：完全相同