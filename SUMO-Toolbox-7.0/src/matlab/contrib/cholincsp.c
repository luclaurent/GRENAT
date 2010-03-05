/******************************************************************************
*
* File        : cholincsp.c
*
* Date        : Friday 25th March 2005.
*
* Author      : Dr Gavin C. Cawley
*
* Description : Mex implementation of the incomplete Cholesky factorization with
* symmetric pivoting [1,section 4.2.9] as described by Fine and
* Scheinberg [2], using the BLAS library.
*
* References  : [1] Golub, G. H. and Van Loan, C. F., "Matrix computations",
* The Johns Hopkins University Press, Baltimore and London,
* third edition, 1996.
*
* [2] Fine, S. and Scheinberg, K., "Efficient SVM training using
* low-rank kernel representations", Journal of Machine Learning
* Research, vol. 2, pp 243-264, December 2001.
*
* To do list  : (i)  Add a bit more error checking on the input
* (ii) Add option to specify the maximum rank of Cholesky factor
*
* History     : 25/03/2005 - v1.00
*
* Copyright   : (c) Dr Gavin C. Cawley, March 2005.
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation; either version 2 of
* the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the Free
* Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
* MA 02111-1307 USA.
*
******************************************************************************/

#include <limits.h>
#include <string.h>
#include <math.h>

#include "mex.h"

#define SWAP(type, a, b) {auto type __tmp = a; a = b; b = __tmp;}

#if defined(__WINDOWS__)||defined(__OS2__)||defined(WIN32)||defined(_MSC_VER)
#define BLAS(f) f
#else
#define BLAS(f) f ## _
#endif

void BLAS(dcopy)(int *n,double *x,int *incx,double *y,int *incy);
double BLAS(ddot)(int *n,double *x,int *incx,double *y,int *incy);
/*void BLAS(daxpy)(int *n,double *alpha,double *x,int *incx,double *y,int *incy);
void BLAS(dscal)(int *n,double *alpha,double *y,int *incy);*/
void BLAS(mkl_dcscmv)(char *transa, int *m, int *k, double *alpha, 
		char *matdescra, double *val, int *indx, int *pntrb,
		int *pntre, double *x, double *beta, double *y);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  mwSize m, n;
  
  /* (sparse) input matrix */
  mwIndex *X_irs, *X_jcs; /* indices */
  double *X_sr; /* actual entries */
  
  /* (sparse) output matrix */
  mwIndex *L_irs, *L_jcs; /* indices */
  double *L_sr; /* actual entries */
  
  /* temporary vector m x 1 */
  double *tmp;
  int idx, idx2;
  
  /* algorithm params */
  int *P; /* permutation indices m x 1 */
  int pivot;
  double tol = mxGetEps(); /*1e-12; */
  int maxRank;
  double trace, l, v, alpha;
  
  /* misc */
  int one = 1;
  int i, j, k; /* general iterators */
  int nzmax;
  
  if (nrhs == 0 || nrhs > 3) {
    mexErrMsgTxt("Wrong number of input arguments");
  }
  
  /* Initialize some variables */
  
  /* input matrix */
  if( !(mxIsSparse(prhs[0]) && mxIsDouble(prhs[0])) ) {
    mexErrMsgTxt("First input argument must be a double sparse matrix.");
  }
  
  /* dimensions */
  m  = mxGetM(prhs[0]); /* number of rows */
  n  = mxGetN(prhs[0]); /* number of columns */
  nzmax = (m*n+m)/2;
  
  if( n != m )
    mexErrMsgTxt("Matrix A should be square.");
  
  /* tolerance */
  if( nrhs > 1 ) {
    if (!(mxIsDouble(prhs[1]) && mxGetM(prhs[1]) == 1 && mxGetN(prhs[1]) == 1 )) {
      mexErrMsgTxt("Second input argument must be of a scalar double.");
    }
    
    tol = mxGetScalar(prhs[1]);
  }

  /* maxRank */
  if( nrhs > 2 ) {
    if (!(mxGetM(prhs[2]) == 1 && mxGetN(prhs[2]) == 1 )) {
      mexErrMsgTxt("Third input argument must be of a scalar.");
    }
    maxRank = mxGetScalar(prhs[2]);
  } else {
    maxRank = m;
  }
  
  /* permutation vector */
  if (nlhs == 2)
  {
    plhs[1] = mxCreateNumericMatrix(1, m, mxINT32_CLASS, mxREAL);
    P     = (int*)mxGetPr(plhs[1]);
  }
  else
    P = (int*)mxCalloc(m, sizeof(int));
  
  for (i = 0; i < m; i++)
  {
    /*
    permutation vector index starts from 1 (matlab style)
    NOTE: old code considered it 0-based -> offset by 1
    */
    P[i] = i + 1;
  }
  
  /* matrices */
  
  /* Input matrix L (sr is column-major) ! */
  /* assume upper triangular ! */
  X_sr  = mxGetPr(prhs[0]); /* real */
  X_irs = mxGetIr(prhs[0]); /* row index: size()=nzmax */
  X_jcs = mxGetJc(prhs[0]); /* column: size()=n+1 */
  
  /* Output matrix L (sr is column-major) ! */
  plhs[0] = mxCreateSparse(m, n, nzmax, mxREAL);
  /*plhs[0] = mxDuplicateArray(prhs[0]);*/
  L_sr  = mxGetPr(plhs[0]); /* real */
  L_irs = mxGetIr(plhs[0]); /* row index: size()=nzmax */
  L_jcs = mxGetJc(plhs[0]); /* column: size()=n+1 */
  
  /*
  memcpy( L_irs, X_irs, nzmax*sizeof(mwIndex) );
  memcpy( L_jcs, X_jcs, (n+1)*sizeof(mwIndex) );
  */
 
  tmp = (double*)mxCalloc(m, sizeof(double));
  
  /* form Cholesky factor */
  /*old: BLAS(dcopy)(&m, X_sr, &one, L_sr, &one);*/
  /* BLAS(dcopy)(&m, X_sr, &m, L_sr, &m); */
  for (i = 0; i < m; ++i) {
    L_jcs[i] = (i*i+i)/2;
    
    /* sr: data */
    if (L_jcs[i] == X_jcs[i])
      L_sr[L_jcs[i]] = X_sr[X_jcs[i]];
    else
      L_sr[L_jcs[i]] = 0;
    
    /* ir: row indices */
    if (i == 0)
      L_irs[i] = 0;
    else {
      memcpy( &L_irs[L_jcs[i]], &L_irs[L_jcs[i-1]], i*sizeof(mwIndex) );
      L_irs[L_jcs[i]+i] = i;
    }
  }
  L_jcs[m] = nzmax;
  
#ifdef DEBUG
  printf( "nlhs: %i , nrhs: %i\n", nlhs, nrhs );
  printf( "tol: %e , maxRank: %u\n", tol, maxRank );
  printf( "nzmax: %i , (m,n)=(%i,%i)\n", nzmax, m, n );

  for (k=0; k < m+1; ++k )
  {
    printf( "%i\n", L_jcs[k] );
  }
  printf( "\n" );
  for (k=0; k < nzmax; ++k )
  {
    printf( "%i\n", L_irs[k] );
    /*L_sr[k] = 0;*/
  }
#endif
  
  /* rows */
  for (i = 0; i < maxRank; ++i) {
    trace = 0.0;
    pivot = -1;
    v     = -DBL_MAX;
    
    /* columns */
    /* j >= i */
    for (j = i; j < m; ++j) {
      /* jc[j+1]-1 is the index of the last nonzero element in the jth column. */
      idx = X_jcs[P[j]]-1; /* full: P[j]*m+P[j] */
      /*l = X_sr[idx] - BLAS(ddot)(&i, L_sr+j, &m, L_sr+j, &m);*/
      l = -BLAS(ddot)(&i, &L_sr[L_jcs[j]], &one, &L_sr[L_jcs[j]], &one);
      if ( X_irs[idx] == P[j]-1 )
	l += X_sr[idx];
      /* else
        l += 0;
      */
      /*printf( "P[j]: %u, X_irs[idx]: %u, idx: %u\n", P[j], X_irs[idx], idx );*/
      
      idx = L_jcs[j+1]-1; /* full: j*m+j */
      L_sr[idx] = l;
      trace += l;
      
      if (l > v) {
	pivot = j;
	v     = l;
      }
    } /* for columns */
    
    if (trace <= tol) {
      break;
    }
    else {
      SWAP(int, P[i], P[pivot]);
      
      /* POSSIBLE SEGFAULT in dcopy's below (if pivot < i) */
      if (pivot < i) {
	char buf[255];
	sprintf( buf, "WARNING: pivot (%i) < i (%i)\n", pivot, i );
	mexErrMsgTxt( buf );
      }
      
      /* old: BLAS(dcopy)(&i, L+i,     &m,   tmp,     &one); */
      /* old: BLAS(dcopy)(&i, L+pivot, &m,   L+i,     &m); */
      /* old: BLAS(dcopy)(&i, tmp,     &one, L+pivot, &m); */ 
      BLAS(dcopy)(&i, &L_sr[L_jcs[i]], &one,   tmp,     &one); /* Li -> tmp */
      BLAS(dcopy)(&i, &L_sr[L_jcs[pivot]], &one,   &L_sr[L_jcs[i]], &one); /* Lpivot -> Li */
      BLAS(dcopy)(&i, tmp, &one, &L_sr[L_jcs[pivot]], &one); /* tmp -> Lpivot */
      
      /* j >= i */
      /* relation P[j] and P[i] UNKNOWN => if else */
      for (j = i; j < m; ++j) {
	
	idx2 = L_jcs[j] + i; /* j+i*m */
	L_sr[idx2] = 0;
	
	/* P[j]+P[i]*m */;
	if( P[j] > P[i] ) {
	  idx = X_jcs[P[j]-1] + P[i] - 1;
	  if ( X_irs[idx] == P[i] - 1 )
	    L_sr[idx2] = X_sr[idx];
	} else {
	  idx = X_jcs[P[i]-1] + P[j] - 1;
	  if ( X_irs[idx] == P[j] - 1 )
	    L_sr[idx2] = X_sr[idx];
	}
      }
      
      v = sqrt(v);
      idx = L_jcs[i+1]-1; /* i+i*m */
      L_sr[idx] = v;
      n = m - i - 1; /* OLD n = m - i; NEW: n = m - i - 1; */
      
      /* j < i */
      for (j = 0; j < i; ++j) {
	idx = L_jcs[i] + j; /* i+j*m */
	alpha = -L_sr[idx];
	
	/* old: BLAS(daxpy)(&n, &alpha, L+i+1+j*m, &one, L+i+1+i*m, &one);*/
	/*BLAS(daxpy)(&n, &alpha, L_sr+L_jcs[i+1]+j, &idx2, L_sr+L_jcs[i]+i+1, &PROBLEM);*/
	
	/* SPARSE (wrong) */
	/*BLAS(daxpyi)(&n, &alpha, L_sr+L_jcs[i+1]+j, L_jcs[i+1]+j, L_sr+L_jcs[i]+i+1)*/
	
	for (k = 0; k < n; ++k)
	  L_sr[L_jcs[i+1 +k]+i] += L_sr[L_jcs[i+1 +k]+j] * alpha;
      }
      
      /* old: BLAS(dscal)(&n, &v, L+i+1+i*m, &one);
      BLAS(dscal)(&n, &v, L_sr+L_jcs[i+1]+i, &PROBLEM);*/
      for (k = 0; k < n; ++k)
	L_sr[L_jcs[i+1 +k]+i] /= v;
      
      
    } /* if trace <= tol */
  }
  
  if( i < m ) {
    /* Regenerate: rank = i */
    nzmax = (i * (2*m-i+1)) / 2; /* OK */
    
    for (j=i+1; j < m; ++j) {
      mwIndex old;
      old = L_jcs[j];
      
      /* update jcs */
      L_jcs[j] = L_jcs[j-1] + i; /* jcs */
      
      /* update irs */
      memcpy( &L_irs[L_jcs[j]], &L_irs[L_jcs[i-1]], i*sizeof(mwIndex) ); /* irs */
      
      /* copy sr */
      memmove( &L_sr[L_jcs[j]], &L_sr[old], i*sizeof(double) ); /* sr */
    }
    L_jcs[m] = L_jcs[m-1] + i;
    
    /* Reallocate */
    L_sr = mxRealloc( L_sr, nzmax );
    L_irs = mxRealloc( L_irs, nzmax );
    /*L_jcs = mxRealloc( L_irs, m ); NOT needed */
    
    /* Set */
    /*mxSetPr(plhs[0], L_sr);
    mxSetIr(plhs[0], L_irs);*/
    /* mxSetJc(plhs[0], L_jcs); NOT needed */
    mxSetM(plhs[0], i); /* rows: */
    mxSetNzmax( plhs[0], nzmax );
  }
  
  /* Debug */
#ifdef DEBUG
  printf( "Final rank: %i of %i\n", i, m ); 
  printf( "nzmax: %i , (m,n)=(%i,%i)\n", nzmax, i, m );
  printf( "Final L_jcs:\n" );
  for (k=0; k < m+1; ++k )
  {
    printf( "%i\n", L_jcs[k] );
  }
  printf( "\n" );
  printf( "Final L_irs:\n" );
  for (k=0; k < nzmax; ++k )
  {
    printf( "%i\n", L_irs[k] );
  }
#endif
    
  /* FREE */
  mxFree( tmp );
  if( nlhs < 2 )
    mxFree( P );
}

/***************************** That's all Folks! *****************************/

