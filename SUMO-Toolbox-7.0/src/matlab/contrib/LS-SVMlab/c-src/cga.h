#ifndef CGA_H
#define CGA_H

#include "memSpec.h"


#define ABS(x)  (x<0 ? -x: x)

double* cga(double* p_x, double* startv, 
	    const double** B, double (*getIJ)(void*, int, int, int), void* A_struct,  
	    int max_itr, double eps, double fi_bound,  
	    int outnum,  int num, int show);

int stop(double delta_prev, double deltaFi, double norm_b, double eps, double fiBound, int k, int itrnum, int show);



#endif
