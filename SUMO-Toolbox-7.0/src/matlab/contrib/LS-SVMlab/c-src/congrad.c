#include "congrad.h"
#include "cga.h"


/* gateway to matlab */
/* arguments:
 *  nlhs = 1,
 *  plhs = X
 *  nrhs = 9,
 *  prhs = A, A_dim ,B, B_dim, Xstart, eps, fi_bound, max_itr, show 
 *  remark: X,Y are stored vertical sequential (like matlab standard)
 */
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[] )
{ 
  double *A, *B, *X;
  const double** B2;
  int a_dim, b_dim;
  unsigned int max_itr,show;
  double eps, fi_bound;
  int* dims;
  int i,j;

  congrad* cg;

  /* Check for proper number of arguments */   
  
  if (nrhs != 9)
    ERRORMSG("9 input arguments required.");
  if (nlhs >1)
    ERRORMSG("Too many output arguments."); 
  
  
  /* Check INPUT: for speedup, put it between comment-signs */
 
  if (!(mxIsNumeric(ADIM_IN) && mxIsNumeric(BDIM_IN)))
    ERRORMSG("A-dimension and B-dimension must be integers;");
  
  a_dim = mxGetScalar(ADIM_IN);
  b_dim = mxGetScalar(BDIM_IN);
  
  if (!mxIsNumeric(A_IN) || !mxIsNumeric(B_IN))
    ERRORMSG("A and B must be arrays of numerics");
  if (!(mxIsNumeric(SHOW_IN)))
    ERRORMSG("show must be either '0' or '1';");
  if (!(mxIsNumeric(MAXITR_IN)))
    ERRORMSG("the maximum of iterations must be an integer;");
  if (!(mxIsNumeric(EPS_IN)))
    ERRORMSG("EPS must be a numerical constant;");
  if (!(mxIsNumeric(FI_BOUND_IN)))
    ERRORMSG("fi_bound must be a numerical constant;");


  
  /* Assign pointers to the various matlab vars */
  
  A = (double*) mxGetPr(A_IN);
  B = (double*) mxGetPr(B_IN);
  eps = mxGetScalar(EPS_IN);
  fi_bound = mxGetScalar(FI_BOUND_IN);
  max_itr = mxGetScalar(MAXITR_IN);
  show = mxGetScalar(SHOW_IN);

  /* Create a matrix for the OUTPUT argument,
   * and initialise the startvalues if not given
   */
  dims = (int*) mxGetDimensions(XSTART);
  if (mxIsEmpty(XSTART) || dims[0]!=2*a_dim || dims[1]!=b_dim){
    X_OUT = mxCreateDoubleMatrix(2*a_dim, b_dim, mxREAL); 
    X = (double*) mxGetPr(X_OUT);
    for (i=0; i<a_dim*b_dim;i++) X[a_dim*b_dim+i] = B[i];
  }
  else
    X_OUT = mxDuplicateArray(XSTART);


  B2 = (const double**) malloc(b_dim*sizeof(double*));
  for (i = 0; i <b_dim; i++) B2[i] = &B[i*a_dim];


  /* Do the actual computations in a subroutine 
   * double* cga(double* p_x, double* startv, 
   *	      const double** B, double (*getIJ)(void*, int, int, int), void* A_struct,  
   *          int max_itr, double eps, double fi_bound,  
   *          int outnum,  int num, int show);
   */
  cg = cg_constuctor(A, a_dim);
  cga(X, &X[a_dim*b_dim], B2, &getIJ,  cg, max_itr, eps, fi_bound, b_dim, a_dim, show);
  cg_destructor(cg);



  /* convert alpha back to a matrix */
  dims = (int*) malloc(2*sizeof(int));
  dims[0] = 2*a_dim;
  dims[1] = b_dim;
  if (mxSetDimensions(X_OUT,dims,2))
    ERRORMSG("cannot set dimensions of alpha");
 
  free(dims);
  free(B2);

  return;    
}
