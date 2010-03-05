#ifndef _KERNEL_CACHE_
#define _KERNEL_CACHE_

#include "memSpec.h"

 #define MAX_CACHE_SIZE 5656

#define MAX(x,y) x<y? y:x                         
#define MIN(x,y) x<y? x:y                         


#ifndef NULL
#define NULL 0
#endif

/* simple one step history cache */
/* an extension is to use a hash table to
 * store as many elements of the kernel matrix as possible,
 * to avoid recomputations 
 */
typedef struct _cache
{
  int _i;
  int _j;
  int _m;
  double _value;
  double** _cache;
  int _size;
}cache;

cache* createCache(int steps);
void   destructCache(cache* c); 

void setCache(cache* c, const int i, const int j, const int m, const double value);
/* value cannot be negative */
double getCache(cache* c, const int i, const int j);

#endif

