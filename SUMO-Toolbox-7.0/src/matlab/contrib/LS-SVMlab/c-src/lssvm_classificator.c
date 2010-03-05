#include "lssvm_classificator.h"



/* 
 * constructor of structure containing all info for classification
 *
 *
 */
lssvm_c* createLSSVMClassificator(const double* svX, const int dimX,
				  const double* svY, const int dimY,
				  const int nb, const double gamma,
				  const double eps, const int max_itr, 
				  const double fi_bound, int show,
				  const char* kernel_type, const double* kernel_pars)
{

  lssvm_c* lc;

  /* initialisations */
 
  lc = (lssvm_c*) MALLOC(sizeof(lssvm_c));

  lc->_kernel = createKernel(kernel_type, kernel_pars); 
  if (!lc->_kernel) {printf("Could not make kernel...\n"); exit(1);}
  setDPR(lc->_kernel, &getDatapointClass, (void*) lc, dimX,dimY, nb);
  

  lc->_inv_gamma = 1.0/gamma;
  lc->_eps   = eps;
  lc->_fi_bound = fi_bound;
  lc->_max_itr = max_itr;
  lc->_svX   = svX;
  lc->_dim_x = dimX;
  lc->_svY   = svY;
  lc->_dim_y = dimY;
  lc->_nb    = nb;
  lc->_show = show;
  lc->_steps = 1;
  lc->_xdelays = 0;
  lc->_ydelays = 0;

  /* init the not-yet-used variables with NULL */
  lc->_alpha = NULL;
  lc->_b = NULL;
  lc->_simX = NULL;
  lc->_simY = NULL;
  
  /* an object (structure) handling all the kernel-stuff is incorporated */
  lc->_kernel = createKernel(kernel_type, kernel_pars); 
  if (!lc->_kernel) {printf("Could not make kernel...\n"); exit(1);}
  /* the kernel has to know how to get datapoint i */
  setDPR(lc->_kernel, &getDatapointClass, (void*) lc, dimX, dimY, nb);


  /* global kernel cache, 
   * - with a size-1 history &
   * - with a large dynamic memory chunk, 
   * is constructed */
  lc->_cache = createCache(MIN(lc->_nb,MAX_CACHE_SIZE) );

  /* return lssvm classificator object */
  return lc;
}



/* destructor
 *
 * release all used resources, memory
 */
void destructLSSVMClassificator(lssvm_c* lc)
{
  destructKernel(lc->_kernel);
  destructCache(lc->_cache);
  FREE(lc);
}



/* get element (i,j) for m-th output vector 
 *
 * use a cache for optimalisation
 */
double computeHIJMClass(void* ptr, int i, int j, int m)
{
  double k,h;
  int hm;
  lssvm_c* lc;

  /* solution for H[nu v] = [1..1 Y]

  /* explicit cast */
  lc = (lssvm_c*) ptr;

  /* computation of H */
  k = getCache(lc->_cache,i,j);
  if (k==-1) 
  {
    k = computeKernelIJ(lc->_kernel, i,j);
    setCache(lc->_cache,i,j,1,k);
  }
  if (m<lc->_dim_y) h = ((lc->_svY[lc->_nb*m+i])*(lc->_svY[lc->_nb*m+j])*k);
  else              h = ((lc->_svY[lc->_nb*(m-lc->_dim_y)+i])*(lc->_svY[lc->_nb*(m-lc->_dim_y)+j])*k);

  if (i==j) h = h + lc->_inv_gamma;  
  return h;

}



/* 
 *
 * compute ls-svm classifier 
 *
 *
 * compute nu and v in H*nu=svY, H*v=1..1
 * s = Y'nu;
 * b = nu'1..1/s and alpha=v-nu*b
 */
double* computeClass(lssvm_c* lc, double* b, double* alpha, double* startv)
{
  int i,j,m;
  double *nu, *v;
  const double **R;
  double *ones, *h;
  double *s, nuh, yh;
  

  /*  H*[v nu]=[1..1 Y]  */
  if (lc->_show) printf("computation of nu and v..\n");
  ones = (double*) MALLOC((lc->_nb)*sizeof(double));
  

  for (i=0; i<lc->_nb; i++) ones[i] = 1.0;
  /* construction of R in AX=R
   * R = **double, because 
   *  c-intern (no matlab constructions involved)
   *  re-use of the same collums
   */
  lc->_R = (const double**) MALLOC((2*lc->_dim_y)*sizeof(double*));
  for (i=0; i<lc->_dim_y;i++) lc->_R[i] = ones;
  for (i=0; i<lc->_dim_y;i++)
    lc->_R[lc->_dim_y+i] = GETYCOLLUMNJ(lc->_svY,lc->_nb,i);



  
  /*for (j=0; j<lc->_nb;j++)
    for (i=0; i<2*lc->_dim_y;i++){ 
      printf(" R[%d,%d]:%f ",i,j,lc->_R[i][j]);
      printf("\n");
      }*/


  /* 
   * conjungate gradient algoritm 
   * with - without startvalues
   */
  if (startv)
    startv = cga(startv, GETYCOLLUMNJ(startv,lc->_nb,(2*lc->_dim_y)),  lc->_R,  &computeHIJMClass, lc,  lc->_max_itr, lc->_eps, lc->_fi_bound, 2*lc->_dim_y, lc->_nb, lc->_show);
  else
    startv = cga(0,0,  lc->_R,  &computeHIJMClass, lc,  lc->_max_itr, lc->_eps, lc->_fi_bound, 2*lc->_dim_y, lc->_nb, lc->_show);


  /* for (i=0; i<2*lc->_nb;i++)
    printf(" cga[%d]:%f ",i,startv[i]);
  */




  v = startv;
   nu  = &startv[lc->_nb*lc->_dim_y];
  /*nu = MALLOC(lc->_dim_y*lc->_nb*sizeof(double));
  for (i=0; i<lc->_dim_y*lc->_nb;i++) nu[i] = startv[lc->_nb*lc->_dim_y+i];
  */
  if (lc->_show) printf("\n\nalpha and b computation..\n");
 
  
  /*for(m=0; m<lc->_dim_y; m++){
      printf("\n m:%d\n",m);
      for (i=0; i<lc->_nb; i++){
	printf("nu[%d]:%f ",i,GETYIJ(nu,lc->_nb,i,m));
	printf("v[%d]:%f ",i,GETYIJ(v,lc->_nb,i,m));
	printf("\n");}
	}*/
  

  
  /* s = Y'*nu 
   * b = nu'*1..1/s
   * alpha = v- nu*b
   */
  s = MALLOC(lc->_dim_y*sizeof(double));
  for(m=0; m<lc->_dim_y; m++){

    s[m] = 0.0;
    b[m] = 0.0;    
    
    /* for (i=0; i<lc->_nb; i++) 
      s[m] = s[m]+nu[m*lc->_nb+i];
      printf("s[%d] = %f \n",m,s[m]);
    */

 
    for (i=0; i<lc->_nb; i++) 
      s[m] = s[m]+GETYIJ(lc->_svY,lc->_nb,i,m)*nu[m*lc->_nb+i];
    
    

    for (i=0; i<lc->_nb; i++)
      b[m] = b[m]+nu[m*lc->_nb+i];
    
    b[m] = b[m]/s[m];
    
    

    for (i=0; i<lc->_nb; i++)
      GETYIJ(alpha,lc->_nb,i,m) = v[m*lc->_dim_y+i]-nu[m*lc->_dim_y+i]*b[m];

    
     


  }

  if (lc->_show){
    for(m=0; m<lc->_dim_y; m++)
      for (i=0; i<lc->_nb; i++)
	printf("Y[%d,%d]:%f; ",i,m,GETYIJ(lc->_svY,lc->_nb,i,m));
    
    printf("\n nu:\n");
    for(m=0; m<lc->_dim_y; m++)
      for (i=0; i<lc->_nb; i++)
    	printf("nu[%d,%d]:%f; ",i,m,GETYIJ(nu,lc->_nb,i,m));
    
    printf("\n v:\n");
    for(m=0; m<lc->_dim_y; m++)
      for (i=0; i<lc->_nb; i++)
    	printf("v[%d,%d]:%f; ",i,m,GETYIJ(v,lc->_nb,i,m));

    printf("\n alpha:\n");
    for(m=0; m<lc->_dim_y; m++)
      for (i=0; i<lc->_nb; i++)
    	printf("alpha[%d,%d]:%f; ",i,m,GETYIJ(alpha,lc->_nb,i,m));
  }





  /* assign results to structure */
  lc->_b = b;
  lc->_alpha = alpha;

  /* HALT to the memory leaks! */
  FREE(ones);
  FREE(lc->_R);
  
  FREE(s);

  return startv;
}



/* 
 * 
 * simulate an LS-SVM for classification
 *
 */
double* simulateClass(lssvm_c* lc, double* simX, double* simY, int nb, double* res)
{
  int i,j,t,d;
  double kt;
  double* At, *Bt, *ff;



  lc->_simX = simX; 
  lc->_simY = simY; 

  if (lc->_alpha == NULL) computeClass(lc,At, Bt,0); 

  if (res==NULL) res = (double*) MALLOC(nb*lc->_nb*sizeof(double));   

  for (i=0; i<nb; i++){                                               
    for (d=0; d<lc->_dim_y; d++) GETYIJ(res, nb, i, d) = lc->_b[d];   
    for (t=0; t<lc->_nb; t++){                                        
      kt = computeKernelIJ(lc->_kernel, -i-1,t);                      
      for (d=0; d<lc->_dim_y; d++)                                    
	GETYIJ(res, nb, i, d) = GETYIJ(res, nb, i, d) + GETYIJ(lc->_svY,lc->_nb,t,d)*GETYIJ(lc->_alpha, lc->_nb, t,d)*kt;     
    }
  }
  return res;
}
 











const double* getDatapointClass(int i, void* l)
{
  lssvm_c* lc;
  int i2;

  lc = (lssvm_c*) l;
  if (i>=0) return GETXROWJ(lc->_svX, lc->_dim_x, i);
  else {i2=-i-1; return GETXROWJ(lc->_simX, lc->_dim_x, i2);}  
}




