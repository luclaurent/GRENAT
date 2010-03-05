/* mex header file for matlab interaction */

#include "/software/matlab6/extern/include/mex.h"

#define ERRORMSG(T) mexErrMsgTxt(T)
#define MALLOC(X) mxMalloc(X)
#define FREE(X) mxFree(X)

#define GETXIJ(X,dim,i,j) X[dim*i+j]
#define GETXROWJ(X,dim,j) &X[dim*j]

#define GETYIJ(Y,dim,i,j) Y[i+dim*j]
#define GETYCOLLUMNJ(Y,dim,d) &Y[dim*d]



typedef struct cg_s
{
  int dim;
  double* A;
} congrad;

/* stuct\object for calculating passing A */
congrad* cg_constuctor(double* A, int dim)
{ congrad* cg; cg = malloc(sizeof(congrad)); cg->A = A; cg->dim=dim; return cg;}

void cg_destructor(congrad* cg){ free(cg);}

double getIJ(void* cg, int x, int y, int m){
  return ((congrad*) cg)->A[x*((congrad*)cg)->dim+y];}



/* Input Arguments */
#define	A_IN	prhs[0]
#define	ADIM_IN	prhs[1]
#define B_IN   prhs[2]
#define	BDIM_IN	prhs[3]
#define XSTART prhs[4]
#define EPS_IN prhs[5]
#define FI_BOUND_IN prhs[6]
#define MAXITR_IN prhs[7]
#define SHOW_IN prhs[8]

/* Output Arguments */
#define	X_OUT	plhs[0]


