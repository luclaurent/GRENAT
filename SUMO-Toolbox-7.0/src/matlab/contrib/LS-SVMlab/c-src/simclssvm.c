#include "simclssvm.h"

/*
 * gateway to matlab 
 * remark: X',Y and alpha are sequentialised vertically
 *
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 

  lssvm_c* lc;
  lssvm_f* lf;

  double *X, *Y, *simX, *simY; 
  double *Y_out;
  double gamma;
  double* alpha, *b;
  char* type;
  int nb, nb_sim, nb_to_sim;
  int x_dim,y_dim;
  int max_itr,show;
  double eps, fi_bound;
  double* kernel_pars;
  char* kernel_type;
  unsigned int n1, n2;
  int* dims;
  double* dyn_pars;
  int nb_effective, nb_sim_effective,  y_dim_effective, x_dim_effective;
  int i,m;
  int buflen, status;

  /* Check for proper number of arguments */

  if (nrhs != 20)
    ERRORMSG("20 input arguments required.");
  if (nlhs >1)
    ERRORMSG("Too many output arguments."); 
  
  
  /* Check INPUT */
  type = mxArrayToString(TYPE_IN);
  if (!(*type == *"class" || *type == *"function" || *type == *"timeserie" || *type==*"dynamic function")) 
    ERRORMSG("type must be 'class','function', 'timeserie' or 'NARX function';");
  if (!mxIsNumeric(Y_IN) || !mxIsNumeric(X_IN))
    ERRORMSG("X and Y must be arrays of numerics");
  if (!mxIsNumeric(Y_SIM) || !mxIsNumeric(X_SIM))
    ERRORMSG("simX and simY must be arrays of numerics");
  if (!(mxIsNumeric(NB_IN)) ||!(mxIsNumeric(NB_TO_SIM)) || !(mxIsNumeric(NB_SIM)))
    ERRORMSG("nb of parameters must be a numeric constant;");
  if (!(mxIsNumeric(X_DIM)))
    ERRORMSG("dimension of X must be a numeric constant;");
  if (!(mxIsNumeric(Y_DIM)))
    ERRORMSG("dimension of Y must be a numeric constant;");
  if (!(mxGetDimensions(GAMMA_IN)[0]==1) ||
      !(mxGetDimensions(GAMMA_IN)[1]==1) ||
      !(mxIsNumeric(GAMMA_IN)))
    ERRORMSG("Gamma must be a single numerical value");
  if (!mxIsChar(KERNEL_IN))
    ERRORMSG("Cannot find kernel function;");
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

  X = (double*)mxGetPr(X_IN);
  Y = (double*)mxGetPr(Y_IN);
  x_dim = mxGetScalar(X_DIM);
  y_dim = mxGetScalar(Y_DIM);
  nb = mxGetScalar(NB_IN);

  simX = (double*)mxGetPr(X_SIM);
  simY = (double*)mxGetPr(Y_SIM);
  nb_sim = mxGetScalar(NB_SIM);
  nb_to_sim = mxGetScalar(NB_TO_SIM);

 if (show) printf(" simulating a model %s, for %d datapoints; \n",type, nb_sim);

  
  if (mxIsEmpty(ALPHA_IN))     ERRORMSG("train alpha's and b before simulating the model ...");
  else {
    alpha = (double*)mxGetPr(ALPHA_IN);
    b = (double*)mxGetPr(B_IN);
  }

  /* Find out how long the input string array is. */
  buflen = (mxGetM(KERNEL_IN) * mxGetN(KERNEL_IN)) + 1;
  kernel_type = MALLOC(buflen*sizeof(char));
  if (kernel_type == NULL) ERRORMSG("Not enough heap space to hold converted string.");
 /* Copy the string data from prhs[0] and place it into buf. */ 
  status = mxGetString(KERNEL_IN, kernel_type, buflen); 
  if (status != 0) ERRORMSG("Could not convert string data.");

  kernel_pars = mxGetPr(KPARS_IN);

  eps = mxGetScalar(EPS_IN);
  fi_bound = mxGetScalar(FI_BOUND_IN);
  max_itr = mxGetScalar(MAXITR_IN);


  /* Do the actual computations in a subroutine */


  /* check first char of type */


  if (*type==*"class")
  {
    nb_effective = nb; y_dim_effective = y_dim;

    Y_OUT = mxCreateDoubleMatrix(nb_to_sim, y_dim_effective, mxREAL); 
    Y_out = mxGetPr(Y_OUT);

    lc = createLSSVMClassificator(X, x_dim, Y, y_dim, nb, gamma, eps,  max_itr,fi_bound, show, kernel_type, kernel_pars);
    if (alpha != NULL) { lc->_alpha = alpha; lc->_b = b; }
    Y_out = simulateClass(lc, simX,simY,nb_sim, Y_out);
    destructLSSVMClassificator(lc);

 
  }

  else if (*type==*"function")
  {

    nb_effective = nb; y_dim_effective = y_dim;

    Y_OUT = mxCreateDoubleMatrix(nb_to_sim, y_dim_effective, mxREAL); 
    Y_out = mxGetPr(Y_OUT);

    lf =  createLSSVMFctEstimator(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars);
    if (alpha != NULL) { lf->_alpha = alpha; lf->_b = b;}
    Y_out = simulateFctEst(lf, simX, simY, nb_sim, nb_to_sim, Y_out);
    destructLSSVMFctEstimator(lf);
  }

  
  else if (*type==*"timeserie")
  {

    if (!(mxIsNumeric(DYN_PARS))) if (*mxGetDimensions(DYN_PARS)<2)
      ERRORMSG("timeserie needs 2 extra parameters: [steps;x_delays]");
    dyn_pars = (double*) mxGetPr(DYN_PARS);

    nb_effective = nb - X_DELAYS - STEPS+1;
    y_dim_effective = x_dim*STEPS;


    Y_OUT = mxCreateDoubleMatrix(nb_to_sim, y_dim_effective, mxREAL); 
    Y_out = mxGetPr(Y_OUT);

    lf =  createLSSVMTimeserie(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars, (int) dyn_pars[0], (int) dyn_pars[1]);
    if (alpha != NULL) {lf->_alpha = alpha; lf->_b = b; }
    Y_out = simulateTimeserie(lf, simX, NULL, nb_sim, nb_to_sim, Y_out);
    destructLSSVMTimeserie(lf);

  }

  else if (*type==*"dynamic function")
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
    x_dim_effective = x_dim*(X_DELAYS-1)+y_dim*(Y_DELAYS);

    Y_OUT = mxCreateDoubleMatrix(nb_to_sim, y_dim_effective, mxREAL); 
    Y_out = mxGetPr(Y_OUT);

    lf =  createLSSVMNARX(X, x_dim, Y, y_dim, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars, STEPS, X_DELAYS, Y_DELAYS);
    if (alpha != NULL) {lf->_alpha = alpha; lf->_b = b; }
    Y_out = simulateNARX(lf, simX, simY, nb_sim, nb_to_sim, Y_out);
    destructLSSVMNARX(lf);

  }

  return;
    
}
