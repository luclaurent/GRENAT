#ifndef LSSVM_CLASSIFICATOR_H_
#define LSSVM_CLASSIFICATOR_H_


#include "memSpec.h"
#include "kernels.h"
#include "cga.h"
#include "kernel_cache.h"




typedef struct Lssvm_classificator
{
  kernel* _kernel;
  cache* _cache;
  
  double* _alpha;
  double* _b;

  double  _inv_gamma;
  double  _eps;
  double  _fi_bound;
  int     _max_itr;
  const double* _svX;
  const double* _simX;
  int     _dim_x;
  const double* _svY;
  const double* _simY;
  int     _dim_y;
  int     _nb;
  int     _show;
  const double* (*_getDatapoint)(int, void*);
  int _xdelays; 
  int _ydelays;
  int _steps;
  const double** _R;
} lssvm_c;


lssvm_c* createLSSVMClassificator(const double* svX, const int dimX,
				  const double* svY, const int dimY,
				  const int nb, const double gamma,
				  const double eps, const int max_itr, 
				  const double fi_bound, int show,  
				  const char* kernel_type, const double* kernel_pars);



double* computeClass(lssvm_c*, double* b, double* alpha, double* startv);

double* simulateClass(lssvm_c* lc, double* simX, double* simY, int nb, double* res);

void destructLSSVMClassificator(lssvm_c*);



/* hulp functions */

double computeHIJMClass(void*, int i, int j, int m);

const double* getDatapointClass(int i, void*);


#endif
