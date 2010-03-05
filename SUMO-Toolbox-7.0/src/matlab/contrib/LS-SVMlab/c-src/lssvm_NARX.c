#include "lssvm_NARX.h"


/* create an object (structure) containing the needed information to calculate the LS-SVM */
lssvm_f* createLSSVMNARX(const double* svX, const int dimX,
			    const double* svY, const int dimY,
			    const int nb, const double gamma,
			    const double eps, const int max_itr,
			    const double fi_bound, int show, 
			    const char* kernel_type, const double* kernel_pars, 
			    int steps, int xdelays, int ydelays)
{
  lssvm_f* lf;
  int i,l,s,m;
  double **R;


  /* initialise the object (structure) */
  lf =  createLSSVMFctEstimator(svX, dimX, svY, dimY, nb, gamma, eps, max_itr, fi_bound, show, kernel_type, kernel_pars);
  lf->_xdelays = xdelays; 
  lf->_ydelays = ydelays;
  lf->_steps = steps;

  /* the effective number of datapoints=targetpoints */
  lf->_nb_effective = lf->_nb - DELAY(lf->_xdelays,lf->_ydelays) - (lf->_steps-1); 

  /* the effective dimension of the datapoints- targetpoints */
  lf->_dim_x_effective = lf->_dim_x*(lf->_xdelays)+lf->_dim_y*lf->_ydelays;
  lf->_dim_y_effective = lf->_dim_y*lf->_steps;



  /* tricky: a (double) 10fold circular buffer, for economical memory use:
   * for explicit construction of a datapoint, a chunk of memory is preserved,
   * we'd like to compare to datapoints in the kernels, so the double memory is 
   * assigned; and the assignment is alternated 
   */
  lf->_xspace1 = (double*) MALLOC(BUFFERSIZE*sizeof(double)*lf->_dim_x_effective);
  lf->_xspace = 0; 
  /* init target point buffer */
  lf->_buffernb = (int*) MALLOC(10*sizeof(int)); 
  for (s=0; s<BUFFERSIZE; s++) lf->_buffernb[s] = 99999999;
  lf->_buffer_in_use = -1;
  

  /* Set pointer array lf->_R 
   * the array of targetpoints is created explicitly
   */
  R = (double**) MALLOC(sizeof(double*)*(lf->_dim_y_effective));
  for (s=0; s<lf->_dim_y;s++)
  {
    R[s] = (double*) MALLOC(sizeof(double)*(lf->_nb_effective+lf->_steps-1));
    for (l=0; l<lf->_nb_effective+lf->_steps-1;l++)
      R[s][l] = GETYIJ(lf->_svY, lf->_nb,l+DELAY(lf->_xdelays, lf->_ydelays),s);
  }
  for (s=lf->_dim_y; s<lf->_dim_y_effective; s++)
    R[s] = &R[s%lf->_dim_y][s/lf->_dim_y];

  lf->_R = (const double**) R;

  

  /* Set function for the retrieval of a ptr to a full datapoint; by making this functions variable, 
   *  an flexible way for extending to timeseries and NARXal systems is introduced.
   */
  lf->_getDatapoint=&getDatapointNARX;

  /* the kernel has to know how to get datapoint i */
  setDPR(lf->_kernel, &getDatapointNARX, (void*) lf, lf->_dim_x_effective, lf->_dim_y_effective, lf->_nb_effective );

  return lf;
}



/* release all the resources (memory) */
void destructLSSVMNARX(lssvm_f* lf)
{
  int i;

  FREE(lf->_xspace1); 
  FREE(lf->_buffernb);
  for (i=1; i<lf->_dim_y; i++) 
    FREE((double*)lf->_R[i]);
  destructLSSVMFctEstimator(lf);
}



/* do the LS-SVM training */
double* computeNARX(lssvm_f* lf, double* b, double* alpha, double* startv)
{
  if (lf->_show) printf("compute NARX...");
  return computeFctEst(lf, b, alpha, startv);
}



/* simulate the trained lssvm */
double* simulateNARX(lssvm_f* lf, double* simX, double* simY, int nb_sim, int nb_to_sim, double* res)
{
  return  simulateFctEst(lf, simX, simY, nb_sim, nb_to_sim, res);
}


/* function to access a datapoint 
 * if t<0, get the datapoint -t, else get support vector t;
 *
 * lf->_nb_sim is the given number of startvalues (# needed past target values)
 * lf->_nb_to_sim is the number of needed simulations (# extra needed data values)
 */
const double* getDatapointNARX(int t, void* l)
{
  int i,j,k,p, n, s;
  lssvm_f* lf;
  double* ptr;

  lf = (lssvm_f*) l;


  for (s=0; s<BUFFERSIZE; s++)
    if (t==lf->_buffernb[s]) 
    {
      lf->_buffer_in_use = lf->_xspace;
      return &lf->_xspace1[s*lf->_dim_x_effective];
    }


  
  if (lf->_buffer_in_use == lf->_xspace) {lf->_xspace = (lf->_xspace+1)%BUFFERSIZE;}

  ptr = &lf->_xspace1[lf->_dim_x_effective*lf->_xspace];


  if (t>=0) {


    for (i=0; i<lf->_xdelays; i++)
      for (j=0; j<lf->_dim_x; j++)    
	ptr[i*lf->_dim_x+j] = GETXIJ(lf->_svX,lf->_dim_x,t+DELAY(lf->_xdelays,lf->_ydelays)-(lf->_xdelays)+i+1,j); 
    for (i=0; i<lf->_ydelays; i++)
      for (j=0; j<lf->_dim_y; j++)    
	ptr[lf->_xdelays*lf->_dim_x+i*lf->_dim_y+j] = GETYIJ(lf->_svY,lf->_nb,t+DELAY(lf->_xdelays,lf->_ydelays)-(lf->_ydelays)+i,j);
  


    lf->_buffernb[lf->_xspace] = t;  


  }


  
  else {

    t=-t-1;

    for (n=0; n<lf->_xdelays; n++) 
      for (k=0; k<lf->_dim_x; k++)    
	ptr[n*lf->_dim_x+k] = GETXIJ(lf->_simX,lf->_dim_x, t+DELAY(lf->_xdelays,lf->_ydelays)-(lf->_xdelays)+n+1,k);
    
  
    for (n=0; n<lf->_ydelays; n++){ 

      p = t+DELAY(lf->_xdelays,lf->_ydelays)-(lf->_ydelays)+n; 
      
      if (p<lf->_nb_sim)
	for (k=0; k<lf->_dim_y; k++)    
	  ptr[lf->_xdelays*lf->_dim_x+lf->_dim_y*n+k] = GETYIJ(lf->_simY,lf->_nb_sim, p,k);
      else
	for (k=0; k<lf->_dim_y; k++)    
	  ptr[lf->_xdelays*lf->_dim_x+lf->_dim_y*n+k] = GETYIJ(lf->_result,lf->_nb_to_sim, p-lf->_nb_sim,k);
    

    }


    lf->_buffernb[lf->_xspace] = -t-1; 


  }


  lf->_buffer_in_use = lf->_xspace;

  lf->_xspace = (lf->_xspace+1)%BUFFERSIZE;

  return (const double*) ptr;
}



