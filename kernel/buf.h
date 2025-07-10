struct buf {
  int valid;   // has data been read from disk?
  int disk;    // does disk "own" buf?
  uint dev;
  uint blockno;
  struct sleeplock lock;
  uint refcnt;
  struct buf *prev; // LRU cache list
  struct buf *next;
  uchar data[BSIZE];
};

// 这个是buf结构体的定义，inode读取之后的addr放在这个data里面

//////////////////////////////////////////
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////