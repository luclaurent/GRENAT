#include "lssvmFILE.h"

int m,n, xdim, ydim, kl, ssv;
double *kernel_pars, gam; 
double eps, fi_bound;
int n_kernel_pars,max_itr;
char* kernel_key;
int n_dyn_pars, *dyn_pars;
double *svX, *svY, *startv;
double *alpha, *b;
char type;
int nb_effective, xdim_effective, ydim_effective;
int nxt, nyt;
double* Xtest,*Ytest,*Y_out;
int t;

/*
 * read input
 *
 *
 *
 *
 */
int read_input(char* filename)
{
   int i,j;
   FILE *fp;
   double d;
   
   if((fp = fopen(filename, "rb")) == NULL)
   {
      printf("cannot open file '%s'",filename);
      exit(1);
   }
   
   /* read the parameter */

   fread(&type, sizeof(char), 1, fp);

   fread(&n, sizeof(int), 1, fp);
   fread(&xdim, sizeof(int), 1, fp);
   fread(&ydim, sizeof(int), 1, fp);

   fread(&n_kernel_pars, sizeof(int), 1, fp);
   kernel_pars = (double*) malloc(n_kernel_pars*sizeof(double));
   for (i=0;i<n_kernel_pars;i++)
     fread(&kernel_pars[i], sizeof(double), 1, fp); 

   fread(&kl, sizeof(int), 1, fp);
   kernel_key = (char*) malloc(kl*sizeof(char));
   for (i=0;i<kl;i++) fread(&kernel_key[i], sizeof(char), 1, fp);


   fread(&n_dyn_pars, sizeof(int), 1, fp);
   dyn_pars = (int*) malloc(n_dyn_pars*sizeof(int));
   for (i=0;i<n_dyn_pars;i++){
     fread(&dyn_pars[i], sizeof(int), 1, fp);
   }

   svX = malloc( n*xdim*sizeof(double) );
   for(i=0; i<n; i++) for(j=0; j<xdim; j++){ 
     fread(&d, sizeof(double), 1, fp);
     GETXIJ(svX,xdim,i,j) = d;
   }


   svY = malloc( n*ydim*sizeof(double) );
   for(i=0; i<ydim; i++)  for(j=0; j<n; j++){
     fread(&d, sizeof(double), 1, fp);
     GETYIJ(svY,n,j,i) = d;
   }


   alpha = malloc( n*ydim*sizeof(double) );
   for(i=0; i<ydim; i++)  for(j=0; j<n; j++)  {
     fread(&d, sizeof(double), 1, fp);
     GETYIJ(alpha,n,j,i) = d;
   }

   b = malloc( ydim*sizeof(double) );
   for(i=0; i<ydim; i++)
       {
           fread(&d, sizeof(double), 1, fp);
           b[i] = d;
       }


   fread(&nxt, sizeof(int), 1, fp);
   if (nxt>0){
     Xtest = malloc(nxt*xdim*sizeof(double) );
     for(i=0; i<nxt; i++) for(j=0; j<xdim; j++)
     {
       fread(&d, sizeof(double), 1, fp);
       GETXIJ(Xtest,xdim,i,j) = d;
     }
   }
   else Xtest=0;



   fread(&nyt, sizeof(int), 1, fp);
   if (nyt>0){
     Ytest = malloc( nyt*ydim*sizeof(double) );
     for(i=0; i<ydim; i++)  for(j=0; j<nyt; j++)
     {
       fread(&d, sizeof(double), 1, fp);
       GETYIJ(Ytest,nyt,j,i) = d;
     }
   }
   else Ytest=0;
   
   fclose(fp);
   return 0;   
}




/* compute solution
 *
 *
 *
 *
 */
int solve()  
{
  int i,j;

  lssvm_c* lc;
  lssvm_f* lf;

  
  
  /* Do the actual computations in a subroutine */



  if (type==*"class")
  {
    nb_effective = n;
    ydim_effective = ydim;

    lc = createLSSVMClassificator(svX, xdim, svY, ydim, n, gam, eps,  max_itr,fi_bound, 0, kernel_key, kernel_pars);
    if (alpha != NULL) { lc->_alpha = alpha; lc->_b = b; } else {ERRORMSG("alpha's need to be trained"); exit(1);}
    Y_out = simulateClass(lc, Xtest, Ytest,nxt, 0); 
    destructLSSVMClassificator(lc);
  }



  else if (type==*"function")
  {
    nb_effective = n;
    ydim_effective = ydim;
    Y_out = malloc(nxt*ydim_effective*sizeof(double));

    lf =  createLSSVMFctEstimator(svX, xdim, svY, ydim, n, gam, eps, max_itr, fi_bound, 0, kernel_key, kernel_pars);
    if (alpha != NULL) { lf->_alpha = alpha; lf->_b = b;} else {ERRORMSG("alpha's need to be trained"); exit(1);}
    Y_out = simulateFctEst(lf, Xtest, Ytest, nxt, nxt, 0);
    destructLSSVMFctEstimator(lf); 
  }




  return 0;
}



/*
 * write solution
 *
 *
 *
 */
int save_sol(char* filename)
{
   int i;
   FILE *fp;
 
   if ((fp = fopen(filename,"wb")) == NULL)
   {
      ERRORMSG("cannot open file");
      exit(1);  
   }


   if(fwrite( &nxt, sizeof(int), 1, fp) !=1)
   {
       ERRORMSG("write error for nb of simulated points");
       exit(1);
   }



   if(fwrite(Y_out, ydim*nxt*sizeof(double), 1, fp) !=1)
   {
       ERRORMSG("write error for Yt");
       exit(1);
   }

   fclose(fp);   
   free(alpha);
   free(b);
   free(kernel_pars);
   free(Y_out);
 return 0;

}



/* main procedure
 *
 */
int main(int argc, char* argv[])
{
  read_input(argv[1]);  
  solve(); 
  save_sol(argv[1]);
}
