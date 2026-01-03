# afifo_ic_env

## 项目说明

本工程实现并验证了一个异步 FIFO（Asynchronous FIFO），支持独立写时钟 / 读时钟域，采用 Binary Pointer + Gray Code + 双触发器同步 的经典结构。

当前版本 RTL + 黑盒 TB 已验证通过。

---

## 设计要点（重要）

### 1. 判满 / 判空必须基于 next pointer

- 写满（wr_full）必须基于 wr_ptr_nxt（下一拍将要写入的位置）判断
- 读空（rd_empty）必须基于 rd_ptr_nxt（下一拍将要读的位置）判断
- 禁止使用当前指针直接判满 / 判空

---

## 写满条件（Gray Code）

FIFO 深度为 2^N，指针宽度为 N+1（最高位用于区分回绕）。

写满条件定义为：

写指针 next 的 Gray Code  
与 读指针同步后的 Gray Code  
高两位相反，其余位完全相同

```verilog
wr_full <=  (wr_ptr_nxt_g[AFIFO_MORE]   ^ rd_ptr_2d[AFIFO_MORE])   &&
            (wr_ptr_nxt_g[AFIFO_MORE-1] ^ rd_ptr_2d[AFIFO_MORE-1]) &&
            (wr_ptr_nxt_g[AFIFO_MORE-2:0] == rd_ptr_2d[AFIFO_MORE-2:0]);
```

## 读空条件（Gray Code）
```verilog
rd_empty <= (wr_ptr_2d[AFIFO_MORE:0] == rd_ptr_nxt_g[AFIFO_MORE:0]);
```
