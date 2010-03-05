#include "lssvm_classificator.h"
#include "lssvm_fctest.h"
#include "lssvm_timeserie.h"
#include "lssvm_NARX.h"

#include "memSpec.h"



/* Input Arguments */
#define X_SIM prhs[0]
#define Y_SIM prhs[1]
#define NB_SIM prhs[2]
#define NB_TO_SIM prhs[3]

#define ALPHA_IN prhs[4]
#define B_IN     prhs[5]

#define	X_IN	prhs[6]
#define X_DIM   prhs[7]
#define	Y_IN	prhs[8]
#define Y_DIM   prhs[9]
#define NB_IN   prhs[10]

#define	TYPE_IN	prhs[11]
#define	GAMMA_IN prhs[12]

#define EPS_IN  prhs[13]
#define FI_BOUND_IN prhs[14]
#define MAXITR_IN prhs[15]
#define	KERNEL_IN prhs[16]
#define	KPARS_IN prhs[17] /* sigma^2 */
#define SHOW_IN  prhs[18]
#define DYN_PARS prhs[19]
#define STEPS  ((int) dyn_pars[0])
#define X_DELAYS ((int) dyn_pars[1])
#define Y_DELAYS ((int) dyn_pars[2])



/* Output Arguments */
#define	Y_OUT	plhs[0]


