#ifndef LSSVM_FILE_H
#define LSSVM_FILE_H


#include <stdio.h>
#include <stdlib.h>

//#define ERRORMSG(T) printf(T)
//%#define MALLOC(X) malloc(X)
//#define FREE(X) free(X)


#include "cga.h"
#include "lssvm_classificator.h"
#include "lssvm_fctest.h"
#include "lssvm_timeserie.h"
#include "lssvm_NARX.h"


#define STEPS    (dyn_pars[0])
#define XDELAYS  (dyn_pars[1])
#define YDELAYS  (dyn_pars[2])

#endif
