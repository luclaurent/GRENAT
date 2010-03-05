#ifndef KERNEL_H_
#define KERNEL_H_

#include "memSpec.h"
#include <stdlib.h>
#include <math.h>







/* possible kernel functions 
 * 
 * for adding other kernels,
 * add kernel_declaration, make new key and adapt kernel constructor;
 */

/* names of different kernel functions */

double kernel_fct_RBF(void*, int, int);
double kernel_fct_lineair(void*, int,int);
double kernel_fct_mlp(void*, int, int);
double kernel_fct_spline(void*, int, int);
double kernel_fct_poly(void* kp, int i, int j);


double norm(int dim, const double* x1, const double* x2);
double dotProduct(int dim, const double* x1, const double* x2);






/* 
 * structure containing the information of the kernel 
 *    the data is given to this structure, as a reference to a function 
 *    that retrieves/composes the datapoints
 */

typedef struct akernel
{
  int _dim_x;
  int _dim_y;
  int _nb;
  const double * _pars;
  double (*kernel_fct) (void*, int, int);
  const double* (*_DPR)(int, void*);
  void* _DPRoptions;
} kernel;

/* constructor and destructor */
kernel* createKernel(const char* kernel_type, const double* pars);

void destructKernel(kernel*);


/* add the parameters for retrieving a datapoint (timeserie, dynamic) */
void setDPR(kernel* k_ptr, 
	    const double* (*dpr)(int, void*), void*, 
	    int, int, int);

/* get the i-th datapoint of the kernel */
#define GETDP(k,i)  (k->_DPR(i,k->_DPRoptions))

/* get the value o the (i,j)th element of the kernel-matrix,
 * for the m-th output
 */
double computeKernelIJ(kernel*, int i, int j);


#endif
