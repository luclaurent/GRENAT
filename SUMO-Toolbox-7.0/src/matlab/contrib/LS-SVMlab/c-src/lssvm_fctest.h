#ifndef LSSVM_FCTEST_H_
#define LSSVM_FCTEST_H_

#include "memSpec.h"
#include "kernels.h"
#include "cga.h"
#include "kernel_cache.h"


typedef struct Lssvm_function_estimator
{
  kernel* _kernel;
  cache* _cache;
  
  double * _alpha;
  double* _b;

  double  _inv_gamma;
  double  _eps;
  double  _fi_bound;
  int     _max_itr;

  const double* _svX;
  const double* _svY;
  int _dim_x;
  int _dim_y;
  int _nb;
  int _show;


  const double* _simX;
  const double* _simY;
  double* _result;
  int _nb_sim; 
  int _nb_to_sim; 
  

  const double* (*_getDatapoint)(int,void*);

  int _xdelays;  
  int _ydelays; 
  int _steps;   
  int _nb_effective; 
  int _dim_x_effective; 
  int _dim_y_effective; 

  const double** _R;

  double* _xspace1; int _xspace; int* _buffernb; int _buffer_in_use;
  

} lssvm_f;





lssvm_f* createLSSVMFctEstimator(const double* svX, const int dimX,
				 const double* svY, const int dimY,
				 const int nb, const double gamma,
				 const double eps, const int max_itr,
				 const double fi_bound, int show, 
				 const char* kernel_type, const double* kernel_pars);


void destructLSSVMFctestimator(lssvm_f*);

double* computeFctEst(lssvm_f*, double* b, double* alpha, double* startv);

double* simulateFctEst(lssvm_f* lf, double* simX, double* simY, int nb_sim, int nb_to_sim, double* res);



/* help functions */ 

double computeHIJMFctEst(void*, int i, int j, int m);

int getDPdelay(lssvm_f* lf);

const double* getDatapointFctEst(int i, void*);



#endif
