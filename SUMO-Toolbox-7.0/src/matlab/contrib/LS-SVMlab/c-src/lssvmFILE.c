#include "lssvmFILE.h"

int show=0;
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

   // type
   fread(&type, sizeof(char), 1, fp);
   //printf("type:%c\n",type);

   // n, x_dim, y_dim
   fread(&n, sizeof(int), 1, fp);
   //printf("nb_data:%d\n",n);
   fread(&xdim, sizeof(int), 1, fp);
   //printf("xdim:%d\n",xdim);
   fread(&ydim, sizeof(int), 1, fp);
   //printf("ydim:%d\n",ydim);

   // kernel pars
   fread(&n_kernel_pars, sizeof(int), 1, fp);
   //printf("n_kernel_pars:%d\n",n_kernel_pars);
   kernel_pars = (double*) malloc(n_kernel_pars*sizeof(double));
   for (i=0;i<n_kernel_pars;i++)
     fread(&kernel_pars[i], sizeof(double), 1, fp); 
   //printf("sig2:%f\n",kernel_pars[0]);

   fread(&kl, sizeof(int), 1, fp);
   //printf("kernel_key:%d,  ",kl);
   kernel_key = (char*) malloc(kl*sizeof(char));
   for (i=0;i<kl;i++) fread(&kernel_key[i], sizeof(char), 1, fp);
   //printf("kernel_key:%s; \n",kernel_key);


   // dyn_pars
   fread(&n_dyn_pars, sizeof(int), 1, fp);
   //printf("n_dyn_pars:%d\n",n_dyn_pars);
   dyn_pars = (int*) malloc(n_dyn_pars*sizeof(int));
   for (i=0;i<n_dyn_pars;i++)
     fread(&dyn_pars[i], sizeof(int), 1, fp); 

   // gam, eps, fi_bound, max_itr
   fread(&gam, sizeof(double), 1, fp);
   //printf("gam:%f\n",gam);
   fread(&eps, sizeof(double), 1, fp);
   //printf("eps:%f\n",eps);
   fread(&fi_bound, sizeof(double), 1, fp);
   //printf("fi_bound:%f\n",fi_bound);
   fread(&max_itr, sizeof(int), 1, fp);
   //printf("max_itr:%d\n",max_itr);

   // svX: rowwise
   svX = malloc( n*xdim*sizeof(double) );
   for(i=0; i<n; i++) for(j=0; j<xdim; j++){ 
     fread(&d, sizeof(double), 1, fp);
     GETXIJ(svX,xdim,i,j) = d;
   }
   //for(i=0; i<n; i++) for(j=0; j<xdim; j++) 
   //  printf(" X[%d,%d]=%f; ",i,j,GETXIJ(svX,xdim,i,j));

   // svY:collumnwise
   svY = malloc( n*ydim*sizeof(double) );
   for(i=0; i<ydim; i++)  for(j=0; j<n; j++){
     fread(&d, sizeof(double), 1, fp);
     GETYIJ(svY,n,j,i) = d;
   }

   
   // startv: one collumn
   fread(&ssv, sizeof(int), 1, fp);
   if (ssv<1) startv=0;
   else{
     //printf("startvalues of size %d; \n",ssv);
     startv = malloc( ssv*sizeof(double) );
     if(!startv){
       printf("Allocation Error.");
       exit(1);
     }
   }

   for(i=0; i<ssv; i++){
     fread(&d, sizeof(double), 1, fp);
     startv[i] = d;
     //printf(" sv[%d]=%f; ",i,startv[i]);
   }


   

   fread(&show, sizeof(int), 1, fp);
   
   fclose(fp);

   if(show==1){
     /* display the parameter */
     printf("innum = %d, num = %d,outnum = %d\n", xdim,n,ydim);
     printf(" sig2 = %f, gam = %f, eps = %f\n\n", kernel_pars[0], gam, eps);
   }
      
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



  //// CLASSIFICATION ////
  if (type==*"class")
  {

    nb_effective = n;
    ydim_effective = ydim;
    alpha   = malloc(n*ydim*sizeof(double));
    b = malloc(ydim*sizeof(double));

    if (ssv!=4*nb_effective*ydim_effective){
      if (ssv!=0) FREE(startv);
      ssv = 4*nb_effective*ydim_effective;
      startv = 0;
      printf("-");
    }
    else printf("+");

    // compute alfa and b 
    lc = createLSSVMClassificator(svX, xdim, svY, ydim, n, gam, eps,  max_itr,fi_bound, show, kernel_key, kernel_pars);
    startv = computeClass(lc, b, alpha, startv);
    destructLSSVMClassificator(lc);
  }



  //// REGRESSION ////
  else if (type==*"function")
  {

    nb_effective = n;
    ydim_effective = ydim;
    alpha   = malloc(n*ydim*sizeof(double));
    b= malloc(ydim*sizeof(double));

    if (ssv!=2*nb_effective*(1+ydim_effective)){
      if (startv!=0) FREE(startv);
      startv=0;
      ssv = 2*nb_effective*(1+ydim_effective);
    }
    else printf("+");

    // compute alfa and b 
    lf =  createLSSVMFctEstimator(svX, xdim, svY, ydim, n, gam, eps, max_itr, fi_bound, show, kernel_key, kernel_pars);
    startv = computeFctEst(lf, b, alpha, startv);
    destructLSSVMFctEstimator(lf); 
  }



  //// TIMESERIES ////
  else if (type==*"timeserie")
  {
    if (n_dyn_pars<2) {ERRORMSG("TIMESERIES function needs 2 extra parameters: [steps;y_delays]"); exit(1);}

    nb_effective = n - XDELAYS - STEPS + 1;
    ydim_effective = xdim*STEPS;
    alpha   = malloc(nb_effective*ydim_effective*sizeof(double));
    b= malloc(ydim_effective*sizeof(double));

    if (ssv!=nb_effective*(1+ydim_effective)){
      free(startv);
      ssv = nb_effective*(1+ydim_effective);
      startv = 0;
      printf("-");
    }
    else printf("+");


    // compute alfa and b 
    lf =  createLSSVMTimeserie(svX, xdim, svY, ydim, n, gam, eps, max_itr, fi_bound, show, kernel_key, kernel_pars, STEPS, XDELAYS);
    computeTimeserie(lf, b, alpha, startv);
    destructLSSVMTimeserie(lf);
  }



  //// NARX MODEL ////
  else if (type==*"dynamic function")
  {
    if (n_dyn_pars<3) {ERRORMSG("NARX function needs 3 extra parameters: [steps;x_delays;y_delays]"); exit(1);}

    //printf("steps: %d, xdelays:%d, ydelays:%d;\n",STEPS,XDELAYS,YDELAYS);

    nb_effective = n-(MAX(YDELAYS,(XDELAYS-1)))-STEPS +1;
    ydim_effective = ydim*STEPS; 
    xdim_effective = xdim*XDELAYS+ydim*YDELAYS;

    if (ssv!=nb_effective*(1+ydim_effective)){
      free(startv);
      ssv = nb_effective*(1+ydim_effective);
      startv = 0;
      printf("-");
    }
    else printf("+");


    alpha   = malloc(nb_effective*ydim_effective*sizeof(double));
    b= malloc(ydim_effective*sizeof(double));

    // compute alfa and b 
    lf =  createLSSVMNARX(svX, xdim, svY, ydim, n, gam, eps, max_itr, fi_bound, show, kernel_key, kernel_pars, STEPS, XDELAYS, YDELAYS);
    computeNARX(lf, b, alpha, startv);
    destructLSSVMNARX(lf);



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

   if(fwrite( &nb_effective, sizeof(int), 1, fp) !=1)
   {
       ERRORMSG("write error for nb");
       exit(1);
   }

   if(fwrite( &ydim_effective, sizeof(int), 1, fp) !=1)
   {
       ERRORMSG("write error for ydim");
       exit(1);
   }

   if(fwrite( b, ydim*sizeof(double), 1, fp) !=1)
   {
       ERRORMSG("write error for b");
       exit(1);
   }

   if(fwrite( alpha, ydim*n*sizeof(double), 1, fp) !=1)
   {
       ERRORMSG("write error for alpha");
       exit(1);
   }

   
   fwrite(&ssv, sizeof(int), 1, fp);
   if(fwrite( startv, ssv*sizeof(double), 1, fp) !=1)
   {
       ERRORMSG("write error for startvalues");
       exit(1);
   }

   fclose(fp);
   
   free(alpha);
   free(startv);
   free(b);
   free(kernel_pars);
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
