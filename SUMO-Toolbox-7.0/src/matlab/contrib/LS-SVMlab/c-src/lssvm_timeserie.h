#ifndef LSSVM_TIMESERIE_H_
#define LSSVM_TIMESERIE_H_

#include "memSpec.h"
#include "kernels.h"
#include "lssvm_fctest.h"



lssvm_f* createLSSVMTimeserie(const double* svX, const int dimX,
			      const double* svY, const int dimY,
			      const int nb, const double gamma,
			      const double eps, const int max_itr,
			      const double fi_bound, int show, 
			      const char* kernel_type, const double* kernel_pars,
			      int steps, int xdelays);

void destructLSSVMTimeserie(lssvm_f*);

double* computeTimeserie(lssvm_f*, double* b, double* alpha, double* startv);

double* simulateTimeserie(lssvm_f* lf, double* simX, double* simY, int nb_sim, int nb_to_sim, double* res);

const double* getDatapointTimeserie(int, void*);


#endif
