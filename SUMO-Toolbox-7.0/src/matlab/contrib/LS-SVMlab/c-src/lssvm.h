
#ifndef _LSSVM_H_
#define _LSSVM_H_

#include "lssvm_classificator.h"
#include "lssvm_fctest.h"
#include "lssvm_timeserie.h"
#include "lssvm_NARX.h"
#include "memSpec.h"



/* Input Arguments */
#define	X_IN	prhs[0]
#define X_DIM   prhs[1]
#define	Y_IN	prhs[2]
#define Y_DIM   prhs[3]
#define NB_IN   prhs[4]
#define	TYPE_IN	prhs[5]
#define	GAMMA_IN prhs[6]

#define EPS_IN prhs[7]
#define FI_BOUND_IN prhs[8]
#define MAXITR_IN prhs[9]
#define STARTVALUES prhs[10]

#define	KERNEL_IN prhs[11]
#define	KPARS_IN prhs[12] /* sigma^2 */

#define SHOW_IN  prhs[13]

#define DYN_PARS prhs[14]
#define STEPS  ((int) dyn_pars[0])
#define X_DELAYS ((int) dyn_pars[1])
#define Y_DELAYS ((int) dyn_pars[2])



/* Output Arguments */
#define	ALPHA_OUT plhs[0]
#define	B_OUT	plhs[1]
#define STARTVALUES_OUT plhs[2]

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);


#endif
