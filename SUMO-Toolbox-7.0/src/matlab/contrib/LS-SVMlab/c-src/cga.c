/*  Conjungate Gradient Algorithm */

#include "memSpec.h"

#include "cga.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SHOW 1
#define DONTSHOW 0


/* conjungate gradient algoritm 
 *
 * stopcriterium 
 *  the algorithm stops iterating if one of the following conditions becomes true:
 *  ->  delta_prev < sqrt(b'b)/eps 
 *     this means : ||residu||<||b||/eps   
 *  ->  abs(deltaFi)<FiBound
 *     this means that the gain per iteration falls under a underbound
 *  ->  k>=max_itr
 */ 
int stop(double delta_prev, double deltaFi, double norm_b, double eps, double FiBound, int k, int itrnum, int show)
{

  if (show) if(k>itrnum) printf("\n No convergence after maximum number of iterations %d \n",itrnum);

  return (k > itrnum)
    || (ABS(deltaFi) < FiBound) 
    || (delta_prev < norm_b*eps);
}




/* conjungate gradient algoritm
 *
 * the basic algorithm:
 *   p_pk is the conjungate direction
 *   p_r  is the residu
 *   p_x  is the temporarily result 
 *
 *  for m=0..outnum=dim(B,2)
 *  {
 *    p_x = 0..0; p_r = B;
 *    p_pk = p_r;
 *    do
 *    {
 *      alpha = p_r' * p_r / p_pk' * A * p_pk;
 *      p_x   = p_x + alpha * p_pk; 
 *      p_r_old = p_r;
 *      p_r   = p_r - alpha * p_pk;
 *   
 *      beta = p_r' * p_r / p_r_old' * p_r_old
 *      p_pk = p_r + beta * p_pk
 *    }
 *    while not stop(..)
 *  }
 *
 *
 * input preconditions:
 *  - A is a 'num'X'num' SYMMETRIC POSITIVE DEFINITE (X'AX>0 for all nonzero X'es) matrix;
 *  - an element of A is requested by calling fct getIJ(A_struct, ..);
 *  - p_x is the variable that will contain the result; 
 *    if empty (p_x=0), a new chunk of memory is allocated to p_x. Don`t forget to free 
 *    this space after use of the result. 
 *    this construction is needed if a matlab matrix is used.
 *  - B is an array containing pointers to the outnum collums of b;
 *
 * postconditions:
 *  - A * p_X =~ B
 *  - p_x is returned
 *
 * remarks:
 *  - the outer iteration over 'outnum' is internalised, for optimisation reasons. 
 *    Each element of A has to be calculated once, the calculated value can be 
 *    used 'outnum' consecutive times.
 *  - A is symmetric, only the upper triangle is used 
 */
double* cga(double* p_x,
	    double* p_pk,
	    const double** B, 
	    double (*getIJ)(void*, int, int, int), 
	    void* A_struct,  
	    int max_itr, double eps, double fi_bound,
	    int outnum, int num, int show)
{

  /* declarations */  
  int i, j, k, x, y, m, z;
  int itrnum;
  double *p_r;
  double *delta_prev, beta, delta_next;
  double *fi, delta_fi, new_fi;
  double *p_Ap, *ff;
  double alpha;
  double sum, Aij, *norm_b;
  int *stopM, general_stop;

  
  

  /* set upperbound for max number of iterations 
   *  in the worst case, each input vector presents a different conjungate direction
   */
  if (max_itr > num) itrnum = num;
  else itrnum = max_itr;

  /* 
   * memory allocation and initialisation 
   */

  /* if no startvalues for p_x,p_pk ...*/
  if(!p_x){
    p_x  = (double*) MALLOC(2*outnum*num*sizeof(double));
    for(m=0; m<outnum;m++) for(i=0; i<num; i++) p_x[m*num+i]=0.0;
    p_pk = &p_x[num*outnum];
    for (m=0;m<outnum;m++) for (i=0;i<num;i++) p_pk[m*num+i] = B[m][i];
  }
  else
    for (m=0;m<outnum;m++) for (i=0;i<num;i++)  
      if (p_pk[m*num+i]==0.0) p_pk[m*num+i] = B[m][i];



  p_r  = (double*) MALLOC(outnum*num*sizeof(double));
  p_Ap = (double*) MALLOC(outnum*num*sizeof(double));

  delta_prev = (double*) MALLOC(outnum*sizeof(double));
  fi         = (double*) MALLOC(outnum*sizeof(double));
  norm_b     = (double*) MALLOC(outnum*sizeof(double));
  stopM = (int*) MALLOC(outnum*sizeof(double));

  if(!p_r || !p_pk || !p_Ap || !p_x || !delta_prev || !fi || !norm_b || !stopM)
  {ERRORMSG("Allocation error in cga."); exit(1);}



  /* initialisation
   */
  for(m=0; m<outnum;m++)
  {
    
    delta_prev[m] = 0.0;
    fi[m] = 0.0;
    norm_b[m] = 0.0;

    /* initialisation of cga */
    if (p_x) 
      for(i=0; i<num; i++) p_r[m*num+i] = p_pk[m*num+i];
    else
      for(i=0; i<num; i++) p_r[m*num+i] = B[m][i];


    for(i=0; i<num; i++)
    {
      delta_prev[m] = delta_prev[m] + p_r[m*num+i]*p_r[m*num+i];
      norm_b[m] = norm_b[m] + B[m][i]*B[m][i];
    }

    /* initialisation of stopcriterium */
    stopM[m] = 0;
  }

  

  

  /* start main cga iteration loop */
  k = 0;
  do
  {
    k++;
    if ( show ) printf("k = %d\n",k);
      
    /* calculate Ap 
     *  - A is symmetric: only the upper triangle is used;
     *  - most inner loop over m = 0..outnum: a calculated value can be used outnum consecutive times
     *    (if A keeps unchanged for different m's)
     */

    for(i=0; i<outnum*num; i++) p_Ap[i] = 0.0;

    for(j=0; j<num; j++)
    {
      /* solely under triangle */
      for(i=0; i<=j; i++)
	for(m=0; m<outnum;m++)
	  if(!stopM[m])
	  {
	    Aij = getIJ(A_struct, i,j,m);
	    p_Ap[num*m+j] = p_Ap[num*m+j] + Aij*p_pk[m*num+i];
	    if (i!=j) p_Ap[num*m+i] = p_Ap[num*m+i] + Aij*p_pk[m*num+j];
	  }
    }



    
    /* calculate 
     *      alpha = p_r' * p_r / p_pk' * A * p_pk;
     *      p_x   = p_x + alpha * p_pk; 
     *      p_r_old = p_r;
     *      p_r   = p_r - alpha * p_pk;
     */
    
    general_stop = 1;
    for(m=0; m<outnum;m++)
    {

      

      if(!stopM[m])
      {
	sum = 0.0;
	for(i=0; i<num; i++) sum = sum + p_pk[m*num+i]*p_Ap[m*num+i]; 
	alpha = delta_prev[m]/sum;

	for(i=0; i<num; i++) p_x[m*num+i] = p_x[m*num+i] + alpha*p_pk[m*num+i]; 

	for(i=0; i<num; i++) p_r[m*num+i] = p_r[m*num+i] - alpha*p_Ap[m*num+i];
	
	delta_next = delta_prev[m];
	delta_prev[m] = 0.0;
	for(i=0; i<num; i++){delta_prev[m] = delta_prev[m] + p_r[m*num+i]*p_r[m*num+i];}
	if( show ) printf("delta  =  %f\n",delta_prev[m]);

	if( show )  printf("itr: %d<%d, deltaFi %f>%f, :||residu||>||b||*eps %f>%f*%f \n", 
		 k,itrnum, delta_fi, fi_bound,delta_prev[m],norm_b[m],eps);
	


	/* computation of gain in cost-function fi(X) = .5*X'AX+ - X'b = .5*X'(b+r) */
	new_fi = 0;
	for (i=0; i<num; i++)
	  new_fi = new_fi + p_x[m*num+i]*(p_r[m*num+i] + B[m][i]);
	
	new_fi = (-0.5)*new_fi;
	delta_fi = fi[m] - new_fi;
	fi[m] = new_fi;

	/* stop condition of main cga loop, for m`th Y-vector */
   
	stopM[m] = stop(delta_prev[m], delta_fi,  norm_b[m], eps, fi_bound, k, itrnum, show);
	/* general stop of main cga loop */
	general_stop = general_stop && stopM[m]; 

 
	/* initialisation next loop, if one 
	 *      beta = p_r' * p_r / p_r_old' * p_r_old
	 *      p_pk = p_r + delta * p_pk
	 */
	if (!stopM[m])
	{
	  beta = delta_prev[m]/delta_next;
	  for(i=0; i<num; i++) p_pk[m*num+i] = p_r[m*num+i] + beta*p_pk[m*num+i];
	}
      }
    }


  }while( !general_stop);
  /* end of cga */
  
/*
  printf("\n\n");
  for(m=0; m<outnum;m++)
    for(i=0; i<num; i++)
      printf("p_x[%d,%d]=%f; ",i,m,p_x[m*num+i]);
  printf("\n\n");
*/
  
  /* free used memory */
  FREE(p_r);
  FREE(p_Ap);

  FREE(delta_prev);
  FREE(norm_b);
  FREE(stopM);
  FREE(fi);

  return p_x;
}




