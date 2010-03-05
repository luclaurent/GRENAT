#include "kernels.h"
#include "math.h"


/*
 * If one wants to add a new kernel, make a new function with 
 * the name of this kernel. Make a declaration of this function
 * in the header file ./c-src/kernels.h, and link the new function
 * to the name of the kernel in the function 'createKernel(...)' 
 * 
 * The source code has to be recompiled (look for details in the manual).
 */ 


/**********************************************************
 *********************** kernel implementations ***********
 **********************************************************/






/* computation of the standard 2-norm */
double norm(int dim, const double* x1, const double* x2)
{
  int t;
  double norm,h;

  norm =0.0;
  for(t=0; t<dim; t++)
  {
    h = x1[t] - x2[t];
    norm = norm + h*h;
  }
  return norm;
}


/* computation of the standard 2-norm */
double dotProduct(int dim, const double* x1, const double* x2)
{
  int t;
  double norm;

  norm =0.0;
  for(t=0; t<dim; t++)
    norm = norm + x1[t]*x2[t];
  return norm;
}




/* possible kernel functions */

/* RBF kernel.... 
 * the parameter is sigma^2
 */
double kernel_fct_RBF(void* kp, int i, int j)
{
  double norm_x;
  kernel* k;

  k = (kernel*) kp;
  norm_x = norm(k->_dim_x, GETDP(k,i), GETDP(k,j));
  
  return exp((- (double) 1/ ((k->_pars[0])) )*norm_x);
}








/*  lineaire kernel, based on the standard dot-product
 * there's no parameter involved
 */
double kernel_fct_lineair(void* kp, int i, int j)
{
  double dp;
  kernel* k;

  k = (kernel*) kp;

  dp = dotProduct(k->_dim_x, GETDP(k,i), GETDP(k,j));
  return dp; 
}


/* multi-layer perceptron kernel */
double kernel_fct_poly(void* kp, int i, int j)
{
  kernel* k;
  double dp;
  k = (kernel*) kp;
  dp = dotProduct(k->_dim_x, GETDP(k,i), GETDP(k,j));
  return pow(dp+(k->_pars[0]),k->_pars[1]);
}



/* multi-layer perceptron kernel */
double kernel_fct_mlp(void* kp, int i, int j)
{
  kernel* k;
  double dp;

  k = (kernel*) kp;
  dp = dotProduct(k->_dim_x, GETDP(k,i), GETDP(k,j));
  return tanh(k->_pars[0]*dp-k->_pars[1]);
}


/* spline kernel */
double kernel_fct_spline(void* kp, int i, int j)
{
  kernel* k;
  double dp;

  k = (kernel*) kp;
  dp = dotProduct(k->_dim_x, GETDP(k,i), GETDP(k,j));
  if (dp<=1) return (2/3)-dp*dp + 0.5*dp*dp*dp;
  else if (dp<=2) return (2-dp)*(2-dp)*(2-dp)/6;
  else return 0;


  return 0;
}









/****************************************************************
 ******** structure containing info for calculation kernel ******
 ****************************************************************/


/* 
 * constructor:
 *   x_dim*nb = length(svX) and y-dim*nb(svY)
 *   it`s not computed because of the overhead...
 *
 */
kernel* createKernel(const char* kernel_type, 
		     const double* pars)
{
  kernel* k_ptr;
  k_ptr = (kernel*)MALLOC(sizeof(kernel));
  k_ptr->_pars = pars;



  /*
   * add here link to new kernel if appropriate
   */ 
  if (!strcmp(kernel_type,"RBF_kernel"))
     k_ptr->kernel_fct = &kernel_fct_RBF;
  else if (!strcmp(kernel_type,"lin_kernel"))
    k_ptr->kernel_fct = &kernel_fct_lineair; 
  else if (!strcmp(kernel_type,"MLP_kernel"))  
    k_ptr->kernel_fct = &kernel_fct_mlp; 
  else if (!strcmp(kernel_type,"spline_kernel"))
    k_ptr->kernel_fct = &kernel_fct_spline;
  else if (!strcmp(kernel_type,"poly_kernel"))
    k_ptr->kernel_fct = &kernel_fct_poly;

  else {
    printf("unknown kernel for C-progam; for possible kernels, look in c-src/kernels.h\n");
    exit(1);
  }
  return k_ptr;
}


/* 
 * add the parameters for retrieving a datapoint (timeserie, dynamic) 
 */
void setDPR(kernel* k_ptr, const double* DPR(int, void*), void* options, int xdim, int ydim, int nb)
{
  k_ptr->_DPR = DPR;
  k_ptr->_DPRoptions = options;
  k_ptr->_dim_x = xdim;
  k_ptr->_dim_y = ydim;
  k_ptr->_nb = nb;
}



/* 
 * get value of kernel matrix of position (i,j)
 */
double computeKernelIJ(kernel* k_ptr, int i, int j)
{
  double ff;
  ff =  k_ptr->kernel_fct(k_ptr, i,j);
  
  return ff;
}




/* 
 * destruct the used memory 
 */
void destructKernel(kernel* k_ptr)
{
  FREE(k_ptr);
  return;
}




