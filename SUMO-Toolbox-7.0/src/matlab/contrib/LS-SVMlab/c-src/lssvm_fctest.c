#include "lssvm_fctest.h"

/* constructor 
 * an C sturcture is initiated, that is used like an object;
 *
 */
lssvm_f* createLSSVMFctEstimator(const double* svX, const int dimX,
				 const double* svY, const int dimY,
				 const int nb, const double gamma,
				 const double eps, const int max_itr, 
				 const double fi_bound, int show,
				 const char* kernel_type, const double* kernel_pars)
{
  lssvm_f* lf;
  double* pp;
  int i,s,m;



  /* test input variables */
  if (nb<=0) ERRORMSG("negative or zero number of support vectors..."); 

  /* allocate memory */
  lf = (lssvm_f*) MALLOC(sizeof(lssvm_f));


  /* initialisate the straightforward variables */
  lf->_inv_gamma = 1.0/gamma;
  lf->_eps   = eps;
  lf->_fi_bound = fi_bound;
  lf->_max_itr = max_itr;
  lf->_svX   = svX;
  lf->_dim_x = dimX;
  lf->_svY   = svY;
  lf->_dim_y = dimY;
  lf->_nb    = nb;
  lf->_show = show;
  lf->_xdelays = 0;
  lf->_ydelays = 0;
  lf->_steps = 0;

  /* init the not-yet-used variables with NULL */
  lf->_alpha = NULL;
  lf->_b = NULL;
  lf->_simX = NULL;
  lf->_simY = NULL;
  
  /* the effective number of datapoints=targetpoints */
  lf->_nb_effective = lf->_nb;
  
  /* the effective dimension of the datapoints- targetpoints */
  lf->_dim_x_effective = lf->_dim_x;
  lf->_dim_y_effective = lf->_dim_y;



  /* Set pointer array lf->_R ; 
   * this is an extra index array over the target variables
   */
  lf->_R = (const double**) MALLOC(sizeof(double*)*(lf->_dim_y_effective));
  for (m=0; m<lf->_dim_y_effective;m++){ 
    lf->_R[m] = GETYCOLLUMNJ(lf->_svY, lf->_nb,m);
  }

  

  /* Set function for the retrieval of a ptr to a full datapoint; by making this functions variable, 
   *  an flexible way for extending to timeseries and dynamical systems is introduced.
   */
  lf->_getDatapoint=&getDatapointFctEst;


  /* an object (structure) handling all the kernel-stuff is incorporated */
  lf->_kernel = createKernel(kernel_type, kernel_pars); 
  if (!lf->_kernel) ERRORMSG("Could not make kernel...\n"); 
  /* the kernel has to know how to get datapoint i */
  setDPR(lf->_kernel, &getDatapointFctEst, (void*) lf, dimX, dimY, nb);


  /* global kernel cache, 
   * - with a size-1 history &
   * - with a large dynamic memory chunk, 
   * is constructed 
   */
  lf->_cache = createCache(MIN(lf->_nb_effective,MAX_CACHE_SIZE)); 

  return lf;
}





/* destructor
 * release all used resources (memory)
 */
void destructLSSVMFctEstimator(lssvm_f* lf)
{
  destructKernel(lf->_kernel);
  destructCache(lf->_cache);
  FREE(lf->_R);
  FREE(lf);
}






/* 
 *  compute alpha and b of the LS-SVM, for regression 
 * 
 * this algorithm contains the standard algorithm; it 
 * contains the core of the calculations for regression.
 *
 * 
 */
double* computeFctEst(lssvm_f* lf, double* b, double* alpha, double* startv)
{
  int i,m, t;
  double *nu,*v;
  double *ones;
  const double** R;
  double* s;

  if (lf->_show) printf("computation of v and nu..\n");
  
  /* construction of R in :H*[nu v]=R=[1..1 Y]  
   * R = **double, R[i] points to the collumn containing the i-th 
   * dimension of the targetpoints
   * the construction of R allows to call CGA just ones;
   *
   * 1. construct ones 
   */
  ones = (double*) MALLOC((lf->_nb_effective)*sizeof(double));
  for (i=0; i<lf->_nb_effective; i++) ones[i] = 1.0;
  /* 
   *2. assign the ptrs to the different elements 
   */
  R = (const double**) MALLOC((lf->_dim_y_effective+1)*sizeof(double*));
  R[0] = ones;
  for (i=0; i<lf->_dim_y_effective;i++) R[i+1] = lf->_R[i];


  /* 
   * conjungate gradient algoritm 
   * with - without startvalues
   * startvalues =[nu v]
   */
  if (startv)
    startv = cga(startv, &startv[(1+lf->_dim_y_effective)*lf->_nb_effective], R,  &computeHIJMFctEst , lf,  lf->_max_itr, lf->_eps, lf->_fi_bound, 1+lf->_dim_y_effective, lf->_nb_effective, lf->_show);
  else
    startv = cga(0,0, R,  &computeHIJMFctEst , lf,  lf->_max_itr, lf->_eps, lf->_fi_bound, 1+lf->_dim_y_effective, lf->_nb_effective, lf->_show);
  
  

  nu = startv;
  v = &startv[lf->_nb_effective];

  if (lf->_show) printf("alpha and b computation..\n");


  /* s = 1..1*nu 
   * b = nu'*Y/s
   * alpha = v-nu*b
   */
  s = MALLOC(sizeof(double));
  s[0] = 0.0;  
  for (i=0; i<lf->_nb_effective; i++) s[0] = s[0] + nu[i];

  for(m=0; m<lf->_dim_y_effective; m++)
  {
    b[m] = 0.0;
    for (i=0; i<lf->_nb_effective; i++)     
      b[m] = b[m]+lf->_R[m][i]*nu[i];
    b[m] = b[m]/s[0];

    for (i=0; i<lf->_nb_effective; i++)
      GETYIJ(alpha,lf->_nb_effective,i,m) = v[m*lf->_nb_effective+i]-nu[i]*b[m];    

  }



  /* assign result to structure */
  lf->_b = b;
  lf->_alpha = alpha;


  /* HALT to the memory leaks! */
  FREE(ones);  
  FREE(R);
  FREE(s);  

  return startv;
}





/* 
 * 
 * simulate an LS-SVM for function estimation 
 *
 */
double* simulateFctEst(lssvm_f* lf, double* simX, double* simY, int nb_sim, int nb_to_sim, double* res)
{
  int i,t,d;
  double kt;
  double* At, *Bt;

  lf->_simX = simX; 
  lf->_simY = simY; 
  lf->_nb_sim = nb_sim;
  lf->_nb_to_sim = nb_to_sim;


  if (res==NULL) res = (double*) MALLOC(nb_to_sim*lf->_dim_y_effective*sizeof(double));   

  lf->_result = res; 

  for (i=0; i<nb_to_sim; i++){                                         

    for (d=0; d<lf->_dim_y_effective; d++) GETYIJ(res, nb_to_sim, i, d) = lf->_b[d];   
    
    for (t=0; t<lf->_nb_effective; t++){                              
      kt = computeKernelIJ(lf->_kernel, -i-1,t);                      
      for (d=0; d<lf->_dim_y_effective; d++)                         
	GETYIJ(res, nb_to_sim, i, d) = GETYIJ(res, nb_to_sim, i, d) + GETYIJ(lf->_alpha, lf->_nb_effective, t,d)*kt;  
      
    }
  }

  return res;
}
  








/*
 *  
 * hulp functions 
 *
 */ 


/* get element (i,j) for m-th output vector 
 * independent on svY...
 * use a cache for optimalisation
 */
double computeHIJMFctEst(void* ptr, int i, int j, int m)
{
  double k;
  lssvm_f* lf;

  /* explicit cast */
  lf = (lssvm_f*) ptr;

  k = getCache(lf->_cache,i,j);
  if (k==-1) 
  {
  k = computeKernelIJ(lf->_kernel, i,j); 
    if (i==j) k = k + lf->_inv_gamma;
    setCache(lf->_cache,i,j,1,k);
  }


  return k;
}


/* the targetpoints have a delay to the begin of all the measurements, 
 * according to the delay of the system
 */
int getDPdelay(lssvm_f* lf)
{
  return MAX(lf->_xdelays, lf->_ydelays);
  
}



/* function for getting datapoint i
 * This callback function cares for not explicitly copying datapoints
 *
 * if i<0, the simulate point -i-1 is taken from lf->_simX, 
 * else the datapoint from lf->_svX is given
 *
 */ 
const double* getDatapointFctEst(int i, void* f)
{
  int i2;
  lssvm_f* lf;
  lf = (lssvm_f*) f;

  if (i>=0)
    return GETXROWJ(lf->_svX, lf->_dim_x, i);
  else{ 
    i2=-i-1;
    return GETXROWJ(lf->_simX, lf->_dim_x, i2);
  }   
}




