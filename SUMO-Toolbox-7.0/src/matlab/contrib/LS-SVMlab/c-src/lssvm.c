#include "lssvm.h"


/* gateway to matlab */
/* arguments:
 *  nlhs = 3,
 *  plhs = alpha ,b, cga_startvalues
 *  nrhs = 15,
 *  prhs = X ,x_dim, Y, y_dim, nb, type, gamma, eps, fi_bound, max_itr, startvalues, kernelfct, kernel_args, show dynpars[step,xdelay,ydelay] 
 * remark: X,Y and alpha are sequentialised vertically
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 

  lssvm_c* lc;
  lssvm_f* lf;

  int given;
  double *alpha,*b, *startv;
  double *X, *Y,gamma;
  char* type;
  int nb,x_dim,y_dim;
  int max_itr,show;
  double eps, fi_bound;
  double* kernel_pars;
  char* kernel_type;
  unsigned int n1, n2;
  int* dims;
  double* dyn_pars;
  int nb_effective, y_dim_effective,x_dim_effective;
  int i,m;
  int   buflen;
  int   status;

  
  /* Check for proper number of arguments */   
  
  if (nrhs != 15)
    ERRORMSG("15 input arguments required.");
  if (nlhs >3)
    ERRORMSG("Too many output arguments."); 
  
  
  /* Check INPUT */
  type = mxArrayToString(TYPE_IN);
  if (!(*type == *"class" || *type == *"function" || *type == *"timeserie" || *type==*"dynamic function")) 
    ERRORMSG("type must be 'class','function', 'timeserie' or 'NARX function';");


  if (!mxIsNumeric(Y_IN) || !mxIsNumeric(X_IN))
    ERRORMSG("X and Y must be arrays of numerics");
  if (!(mxIsNumeric(NB_IN)))
    ERRORMSG("nb of parameters must be a numeric constant;");
  if (!(mxIsNumeric(X_DIM)))
    ERRORMSG("dimension of X must be a numeric constant;");
  if (!(mxIsNumeric(Y_DIM)))
    ERRORMSG("dimension of Y must be a numeric constant;");

  if (!mxIsChar(KERNEL_IN))
    ERRORMSG("Cannot find kernel function;");
  if (!(mxGetDimensions(GAMMA_IN)[0]==1) ||
      !(mxGetDimensions(GAMMA_IN)[1]==1) ||
      !(mxIsNumeric(GAMMA_IN)))
    ERRORMSG("Gamma must be a single numerical value");

  if (!(mxIsNumeric(KPARS_IN)))
    ERRORMSG("the kernel arguments must be inclosed in a numeric array;");
  if (!(mxIsNumeric(SHOW_IN)))
    ERRORMSG("show must be either '0' or '1';");

  if (!(mxIsNumeric(MAXITR_IN)))
    ERRORMSG("the maximum of iterations must be an integer;");
  if (!(mxIsNumeric(EPS_IN)))
    ERRORMSG("EPS must be a numerical constant;");
  if (!(mxIsNumeric(FI_BOUND_IN)))
    ERRORMSG("fi_bound must be a numerical constant;");



  /* Assign pointers to the various matlab vars */

  show = mxGetScalar(SHOW_IN);
  if (show) printf("training of LS-SVM, for:\n");

  X = (double*)mxGetPr(X_IN);
  Y = (double*)mxGetPr(Y_IN);
  x_dim = mxGetScalar(X_DIM);
  y_dim = mxGetScalar(Y_DIM);
  nb = mxGetScalar(NB_IN);

  gamma = mxGetScalar(GAMMA_IN);
  if (show) printf("- gamma:%f ;\n",(1.0)*gamma);
  kernel_pars = mxGetPr(KPARS_IN);
  if (show) printf("- sigma:%f ;\n\n",(1.0)* kernel_pars[0]);

  /* Find out how long the input string array is. */
  buflen = (mxGetM(KERNEL_IN) * mxGetN(KERNEL_IN)) + 1;
  /* Allocate enough memory to hold the converted string. */ 
  kernel_type = MALLOC(buflen*sizeof(char));
  if (kernel_type == NULL) ERRORMSG("Not enough heap space to hold converted string.");
 /* Copy the string data from prhs[0] and place it into buf. */ 
  status = mxGetString(KERNEL_IN, kernel_type, buflen); 
  if (status != 0) ERRORMSG("Could not convert string data.");
  if (show) printf("- kernel:%s ;\n",kernel_type);


  eps = mxGetScalar(EPS_IN);
  fi_bound = mxGetScalar(FI_BOUND_IN);
  max_itr = mxGetScalar(MAXITR_IN);


  /* Do the actual computations in a subroutine */


  /* check first char of type */



  if (*type==*"class")
  {

    dims = (int*)  mxGetDimensions(STARTVALUES);
    if (mxIsEmpty(STARTVALUES) || dims[0]*dims[1]!=2*nb*(2*y_dim)){
      STARTVALUES_OUT=mxCreateDoubleMatrix(nb,2*(2*y_dim), mxREAL);
      printf("-");
    }    
    else{
      STARTVALUES_OUT = mxDuplicateArray(STARTVALUES);
      printf("+");
    }

    startv = mxGetPr(STARTVALUES_OUT);

    ALPHA_OUT = mxCreateDoubleMatrix(nb, y_dim, mxREAL);     
    B_OUT = mxCreateDoubleMatrix(1,y_dim,mxREAL);
    alpha = mxGetPr(ALPHA_OUT);    
    b = mxGetPr(B_OUT);

    lc = createLSSVMClassificator(X, x_dim, Y, y_dim, nb, gamma, eps,  max_itr,fi_bound, show, kernel_type, kernel_pars);
    computeClass(lc, b, alpha, startv);
    destructLSSVMClassificator(lc);
    nb_effective = nb; y_dim_effective = y_dim;

  }


  else if (*type==*"function estimation")
  {
    nb_effective = nb; y_dim_effective = y_dim;

    dims = (int*)  mxGetDimensions(STARTVALUES);
    if (mxIsEmpty(STARTVALUES) || dims[0]*dims[1]!=2*nb_effective*(1+y_dim_effective))
      {
	STARTVALUES_OUT=mxCreateDoubleMatrix(nb_effective,2*(1+y_dim_effective), mxREAL);
      }
    else 
    { 
      STARTVALUES_OUT = mxDuplicateArray(STARTVALUES);
    }
    startv = mxGetPr(STARTVALUES_OUT);


    ALPHA_OUT = mxCreateDoubleMatrix(nb_effective, y_dim_effective, mxREAL);     
    B_OUT = mxCreateDoubleMatrix(1,y_dim_effective,mxREAL);
    alpha = mxGetPr(ALPHA_OUT);    
    b = mxGetPr(B_OUT);


    lf =  createLSSVMFctEstimator(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars);
    computeFctEst(lf, b, alpha, startv);
    destructLSSVMFctEstimator(lf);
  }



  else if (*type==*"timeserie")
  {
    if (!(mxIsNumeric(DYN_PARS))) if (*mxGetDimensions(DYN_PARS)<2) 
      ERRORMSG("timeserie needs 2 extra parameters: [steps;x_delays]");
    dyn_pars = (double*) mxGetPr(DYN_PARS); 

    nb_effective = nb - X_DELAYS - STEPS+1;
    y_dim_effective = x_dim*STEPS;

    
    dims = (int*)  mxGetDimensions(STARTVALUES);
    if (mxIsEmpty(STARTVALUES) || dims[0]*dims[1]!=2*nb_effective*(1+y_dim_effective)){
      STARTVALUES_OUT=mxCreateDoubleMatrix(nb_effective,2*(1+y_dim_effective), mxREAL);
      printf("-");
    }
    else{
      STARTVALUES_OUT = mxDuplicateArray(STARTVALUES);
      printf("+");
    }
    startv = mxGetPr(STARTVALUES_OUT);

    ALPHA_OUT = mxCreateDoubleMatrix(nb_effective, y_dim_effective, mxREAL);     
    B_OUT = mxCreateDoubleMatrix(1,y_dim_effective,mxREAL);
    alpha = mxGetPr(ALPHA_OUT);    
    b = mxGetPr(B_OUT);


    lf =  createLSSVMTimeserie(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars, (int) dyn_pars[0], (int) dyn_pars[1]);
    computeTimeserie(lf, b, alpha, startv);
    destructLSSVMTimeserie(lf);
    


  }

  else if (*type==*"NARX")
  {


    if (!(mxIsNumeric(DYN_PARS))) if (*mxGetDimensions(DYN_PARS)<3)
      ERRORMSG("NARX function needs 3 extra parameters: [steps;x_delays;y_delays]");
    dyn_pars = (double*) mxGetPr(DYN_PARS);

    if (X_DELAYS< 0) ERRORMSG("xdelays has to be larger or equal to 0"); 
    if (Y_DELAYS< 0) ERRORMSG("ydelays has to be larger or equal to 0");
    if (STEPS< 0)    ERRORMSG("steps has to be larger then  0");

    if ((int) (X_DELAYS-1) > Y_DELAYS)
      nb_effective = nb - (X_DELAYS-1) - STEPS+1;
    else
      nb_effective = nb - Y_DELAYS - STEPS +1;
    y_dim_effective = y_dim*STEPS; 
    x_dim_effective = x_dim*X_DELAYS+y_dim*Y_DELAYS;

    printf("lssvm: nbe: %d; dimxe: %d; dimye: %d; \n",nb_effective,x_dim_effective,y_dim_effective);

    dims = (int*)  mxGetDimensions(STARTVALUES);
    if (mxIsEmpty(STARTVALUES) || dims[0]*dims[1]!=2*nb_effective*(1+y_dim_effective))
      {STARTVALUES_OUT=mxCreateDoubleMatrix(nb_effective,2*(1+y_dim_effective), mxREAL); printf("-");}
    else 
      {STARTVALUES_OUT = mxDuplicateArray(STARTVALUES); printf("+");}
    startv = mxGetPr(STARTVALUES_OUT);


    ALPHA_OUT = mxCreateDoubleMatrix(nb_effective, y_dim_effective, mxREAL);     
    B_OUT = mxCreateDoubleMatrix(1,y_dim_effective,mxREAL);
    alpha = mxGetPr(ALPHA_OUT);    
    b = mxGetPr(B_OUT);

    lf =  createLSSVMNARX(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars, STEPS, X_DELAYS, Y_DELAYS);
    computeNARX(lf, b, alpha, startv);
    destructLSSVMNARX(lf);



  }

  return;
    
}
