#include "lssvm_ppt.h"

double My_variable = 3.0;

void lssvm_train(double* alpha, double* b, double *X, int x_dim, double *y_dim, int y_dim, int nb, char* type, double gamma, char* kernelfct, double* kernel_args)
{
  lssvm_train_full(alpha, b, X,x_dim,y_dim,y_dim,nb,type,gamma,1e-16,1e-16,1000,0,kernelfct,kernel_args,0,0);
}


void lssvm_train_full(double* alpha, double* b, double *X, int x_dim, double *y_dim, int y_dim, int nb, char* type, double gamma, double eps, 
		 double fi_bound, int max_itr, double startvalues, char* kernelfct, double* kernel_args, int show, double* dynpars)
{ 

  lssvm_c* lc;
  lssvm_f* lf;

  int given;
  unsigned int n1, n2;
  int* dims;
  int nb_effective, y_dim_effective,x_dim_effective;
  int i,m;
  int buflen;
  int status;

  
  if (show) printf("- kernel:%s ;\n",kernel_type);



  /* Do the actual computations in a subroutine */



  if (*type==*"class")
  {
    nb_effective = nb; y_dim_effective = y_dim;

    dims = (int*)  mxGetDimensions(STARTVALUES);
    if (mxIsEmpty(STARTVALUES) || dims[0]*dims[1]!=2*nb*(2*y_dim)){
      STARTVALUES_OUT=mxCreateDoubleMatrix(nb,2*(2*y_dim), mxREAL);
      printf("-");
    }    
    else{
      STARTVALUES_OUT = mxDuplicateArray(STARTVALUES);
      printf("+");
    }

    startv = MALLOC(nb*2*(2*y_dim)*sizeof(double));


    free(alpha); alpha = malloc(nb*y_dim*sizeof(double));
    free(b);     b     = malloc(y_dim*sizeof(double));

    lc = createLSSVMClassificator(X, x_dim, Y, y_dim, nb, gamma, eps,  max_itr,fi_bound, show, kernel_type, kernel_pars);
    computeClass(lc, b, alpha, startv);
    destructLSSVMClassificator(lc);
  }


  /*else if (*type==*"function estimation")
  {
    nb_effective = nb; y_dim_effective = y_dim;

    startv = malloc(nb_effective*2*(1+y_dim_effective)*sizeof(double));

    ALPHA_OUT = mxCreateDoubleMatrix(nb_effective, y_dim_effective, mxREAL);     
    B_OUT = mxCreateDoubleMatrix(1,y_dim_effective,mxREAL);
    alpha = mxGetPr(ALPHA_OUT);    
    b = mxGetPr(B_OUT);


    lf =  createLSSVMFctEstimator(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars);
    computeFctEst(lf, b, alpha, startv);
    destructLSSVMFctEstimator(lf);
  }
  */
  return;
    
}
