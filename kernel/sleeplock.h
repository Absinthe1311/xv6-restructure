// Long-term locks for processes
struct sleeplock {
  uint locked;       // Is the lock held?
  struct spinlock lk; // spinlock protecting this sleep lock
  
  // For debugging:
  char *name;        // Name of lock.
  int pid;           // Process holding lock
};


//////////////////////////////////////////
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////
