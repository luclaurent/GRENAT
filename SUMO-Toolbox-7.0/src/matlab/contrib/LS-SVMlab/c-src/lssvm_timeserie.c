#include "lssvm_timeserie.h"


/* create an object (structure) containing the needed information to calculate the LS-SVM */
lssvm_f* createLSSVMTimeserie(const double* svX, const int dimX,
			      const double* svY, const int dimY,
			      const int nb, const double gamma,
			      const double eps, const int max_itr,
			      const double fi_bound, int show, 
			      const char* kernel_type, const double* kernel_pars, 
			      int steps, int xdelays)
{
  lssvm_f* lf;
  int i,l,s,m;
  double **R;

  if (xdelays<=0) {printf("xdelays has to be larger then 0"); exit(1);}

  /* initialise the object (structure) */
  lf =  createLSSVMFctEstimator(svX, dimX, svY, 0, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars);
  lf->_xdelays = xdelays; 
  lf->_ydelays = 0;
  lf->_steps = steps;

  /* the effective number of datapoints=targetpoints */
  lf->_nb_effective = lf->_nb - lf->_xdelays - lf->_steps+1;  

  /* the effective dimension of the datapoints- targetpoints */
  lf->_dim_x_effective = lf->_dim_x*lf->_xdelays;
  lf->_dim_y_effective = lf->_dim_x*lf->_steps;


  /* Set pointer array lf->_R 
   * the array of targetpoints is created explicitly
   */
  R = (double**) MALLOC(sizeof(double*)*lf->_dim_y_effective);
  for (s=0; s<lf->_dim_x;s++)
  {
    R[s] = (double*) MALLOC(sizeof(double)*(lf->_nb_effective+lf->_steps-1));
    for (l=0; l<lf->_nb_effective+lf->_steps-1;l++)
      R[s][l] = GETXIJ(lf->_svX, lf->_dim_x,(l+lf->_xdelays),s);
  }
  for (s=lf->_dim_x; s<lf->_dim_y_effective; s++)
    R[s] = &R[s%lf->_dim_x][s/lf->_dim_x];

  lf->_R = (const double**) R;


  /* Set function for the retrieval of a ptr to a full datapoint; by making this functions variable, 
   *  an flexible way for extending to timeseries and dynamical systems is introduced.
   */
  lf->_getDatapoint=&getDatapointTimeserie;

  /* the kernel has to know how to get datapoint i */
  setDPR(lf->_kernel, &getDatapointTimeserie, (void*) lf, lf->_dim_x_effective, lf->_dim_y_effective, lf->_nb_effective );


  /* a chunk of memory is allocated, for repeated assembling the datapoints */ 
  lf->_xspace1 = (double*) MALLOC(sizeof(double)*lf->_dim_x_effective);
  /* init target point buffer */
  lf->_buffernb = (int*) MALLOC(2*sizeof(int)); 
  lf->_buffernb[0] = -1;

  return lf;
}



/* release all the resources (memory) */
void destructLSSVMTimeserie(lssvm_f* lf)
{
  int i;

  FREE(lf->_buffernb);
  for (i=1; i<lf->_dim_x; i++) FREE((double*) lf->_R[i]);
  destructLSSVMFctEstimator(lf); 
}

/* do the LS-SVM training */
double* computeTimeserie(lssvm_f* lf, double* b, double* alpha, double* startv)
{
  return computeFctEst(lf, b, alpha, startv);
}

/* simulate the trained lssvm */
double* simulateTimeserie(lssvm_f* lf, double* simX, double* simY, int nb_sim, int nb_to_sim, double* res)
{
  return simulateFctEst(lf, simX, simY, nb_sim, nb_to_sim, res);
}



/* function to access a datapoint 
 * datapoints X are sequencial : [ |/|/|/| ...]
 * result is Y sequencial : [_____ ..]'
 */
const double* getDatapointTimeserie(int i, void* f)
{
  lssvm_f* lf;
  double* ptr;
  int t,k,n;

  lf = (lssvm_f*) f;
  

  if (i>=0)  return GETXROWJ(lf->_svX,lf->_dim_x,i) ; 
  else{
    i=-i-1;
    ptr = lf->_xspace1;


    if (i==lf->_buffernb[0]) return lf->_xspace1;

    for (n=0; n<lf->_xdelays; n++){ 

      if ((i+n)<lf->_nb_sim)
	for (k=0; k<lf->_dim_x; k++)    
	  ptr[n*lf->_dim_x+k] = GETXIJ(lf->_simX,lf->_dim_x,(i+n),k);
      
      else 
	for (k=0; k<lf->_dim_x; k++)    
	  ptr[n*lf->_dim_x+k] = GETYIJ(lf->_result,lf->_nb_to_sim,((i+n)-lf->_nb_sim), k);    
      
    }
  }

  lf->_buffernb[0] = i; 
  return (const double*) ptr;
}


