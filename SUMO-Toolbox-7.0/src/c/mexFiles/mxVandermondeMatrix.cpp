#include "mex.h"
#include <cstring>

enum bfType { bfPOWER=0, bfCHEBYSHEV=1 };


void mexFunction(
	int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[] )
{	
	if ( nlhs != 1 ) {
		mexErrMsgTxt( "Exactly one output required" );
	}
	
	if ( nrhs != 3 ) {
		mexErrMsgTxt( "Points, degrees and basisfunction as parameters" );
	}
	
	int d = mxGetN( prhs[0] );
	int d2 = mxGetN( prhs[1] );
	int d3 = mxGetN( prhs[2] );
	int N = mxGetM( prhs[0] );
	int M = mxGetM( prhs[1] );
	
	int i, j, k, l;

	if ( d != d2 || d != d3 ) {
		mexErrMsgTxt( "Degree mismatch between parameters" );
	}
	
	// Extract basis function types by calling func2str matlab function
	bfType *basisFunction = new bfType[d];
	for ( k=0;k<d;k++ ) {
		mxArray* in[1];
		mxArray* out[1];
		in[0] = mxGetCell( prhs[2], k );
		out[0] = 0;
		mexCallMATLAB( 1,out,1,in, "func2str" );
		char bf[128];
		mxGetString( out[0], bf, 128 );

		if ( strcmp( bf, "powerBase" ) == 0 )
			basisFunction[k] = bfPOWER;
		else if ( strcmp( bf, "chebyshevBase" ) == 0 )
			basisFunction[k] = bfCHEBYSHEV;
		else
			mexErrMsgTxt( "Basis function type unknown" );
		
		mxDestroyArray( out[0] );
	}
	
	double* points = mxGetPr( prhs[0] );
	double* degrees = mxGetPr( prhs[1] );
	
	plhs[0] = mxCreateDoubleMatrix( N,M,mxREAL );
	double* result = mxGetPr( plhs[0] );
	
	int maxDegree,index;
	double point;
	double *bfValues = 0;

	for ( i=0;i<M*N;i++ )
		result[i] = 1.0;
	
	for (k=0;k<d;k++ ) {
		maxDegree = 0;
		for (j=0;j<M;j++ )
			if ( degrees[k*M+j] > maxDegree )
				maxDegree = (int) degrees[k*M+j];
		
		if ( maxDegree == 0 )
			continue;
		
		bfValues = new double[N*(maxDegree+1)];
		index = 0;
		
		switch ( basisFunction[k] ) {
			case bfPOWER:
				for (i=0;i<N;i++ ) {
					point = points[k*N+i];
					bfValues[index++] = 1.0;
					for (l=0;l<maxDegree;l++ ) {
						bfValues[index] = bfValues[index-1] * point;
						index++;
					}
				}
				break;

			case bfCHEBYSHEV:
				for (i=0;i<N;i++ ) {
					point = points[k*N+i];
					bfValues[index++] = 1.0;
					bfValues[index++] = 2.0 * point;
					for (l=2;l<=maxDegree;l++ ) {
						bfValues[index] = 2.0 * point * bfValues[index-1] - bfValues[index-2];
						index++;
					}
				}
				break;
		}
		
		for (j=0;j<M;j++ ) {
			index = (int) degrees[k*M+j];
			for (i=0;i<N;i++,index+=maxDegree+1) {
				result[j*N+i] *= bfValues[index];
			}
		}
		
		delete[] bfValues;
		delete[] basisFunction;
	}
}
