#ifndef MEM_SPECIFIC_H
#define MEM_SPECIFIC_H

/* 
 * header file including all macro's, specific for the 
 * programming context. If one makes a standalone application, 
 * memSpec2.h should be included. For use with the MATLAB CMEX 
 * compiler, this macros should be included.
 *
 */

#define ERRORMSG(T) printf(T)
#define MALLOC(X) malloc(X)
#define FREE(X) free(X)

#define GETXIJ(X,dim,i,j) X[dim*i+j]
#define GETXROWJ(X,dim,j) (&X[dim*j])

#define GETYIJ(Y,dim,i,j) Y[i+dim*j]
#define GETYCOLLUMNJ(Y,dim,d) (&Y[dim*d])


#define MAX(x,y) x<y? y:x                         
#define MIN(x,y) x<y? x:y                         


#endif
