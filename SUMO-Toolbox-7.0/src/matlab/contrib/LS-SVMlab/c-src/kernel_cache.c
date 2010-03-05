#include "kernel_cache.h"
#include <math.h>

/* simple one step history cache 
 * this optimalisation turns out to accelerate the algoritm
 * a 20% (test done for y_dim =1; RBF_kernel)
 */
/* an extension is to use a hash table to
 * store as many elements of the kernel matrix as possible,
 * to avoid recomputations 
 */
cache* createCache(int steps)
{ 
  int i;
  cache* c;

  /* init cache structure */
  c = (cache*) MALLOC(sizeof(cache));
  
  /* init 1-step cache */
  c->_i=-1; c->_j=-1; c->_m=-1;c->_value=0.0;

  /* init large cache */
  c->_size = steps;
  c->_cache = (double**) MALLOC(c->_size*sizeof(double*));
  for (i=0; i<c->_size; i++) c->_cache[i] = NULL;

  
  return c; 
}


void destructCache(cache* c)
{
  int j;

  


  /* free memory of large cache */
  for (j=0; j<c->_size; j++) if (c->_cache[j]!=NULL) FREE(c->_cache[j]); 
  FREE(c->_cache);

  /* free cache structure */
  FREE(c);
} 


void setCache(cache* c, const int i, const int j, const int m, const double value) 
{
  int t;

  c->_i=i; 
  c->_j=j; 
  c->_m=m; 
  c->_value=value;

  /* is there still place in the cache? */
  if (j<c->_size && i<c->_size)
  {
    
    /* allocate new memory for a new matrix row */
    if (c->_cache[j]==NULL) {
      c->_cache[j] = (double*) MALLOC((j+1)*sizeof(double)); 
      for (t=0; t<j+1; t++) c->_cache[j][t] = -1;
    }
    /* set cache */
    c->_cache[j][i] = value;
  }
  
}


/* value cannot be negative */
double getCache(cache* c, const int i, const int j)
{
  double res;
  int jt,it;

  /* 1-step cache hit? */
  res = (i==c->_i && j==c->_j)||(i==c->_j && j==c->_i)?   c->_value:  -1;
  if (res>-1) return res; 
  
  /* large cache hit? */
  jt = MAX(j,i);
  it = MIN(j,i);
  if (jt<c->_size && c->_cache[jt]!=NULL && c->_cache[jt][it]!=-1) 
    return c->_cache[jt][it];

  /* cache miss */
  return -1;

}


