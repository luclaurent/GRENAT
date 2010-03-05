#ifndef LSSVM_NARX_H_
#define LSSVM_NARX_H_

#include "memSpec.h"
#include "kernels.h"
#include "lssvm_fctest.h"



#define DELAY(xd, yd) (((xd-1)>yd) ? (xd-1) : yd)
#define BUFFERSIZE 2

lssvm_f* createLSSVMNARX(const double* svX, const int dimX,
			    const double* svY, const int dimY,
			    const int nb, const double gamma,
			    const double eps, const int max_itr,
			    const double fi_bound, int show, 
			    const char* kernel_type, const double* kernel_pars,
			    int steps, int xdelays, int ydelays);

void destructLSSVMNARX(lssvm_f*);

double* computeNARX(lssvm_f*, double* b, double* alpha, double* startv);

double* simulateNARX(lssvm_f* lf, double* simX, double* simY, int nb_sim, int nb_to_sim, double* res);

const double* getDatapointNARX(int, void*);



#endif

