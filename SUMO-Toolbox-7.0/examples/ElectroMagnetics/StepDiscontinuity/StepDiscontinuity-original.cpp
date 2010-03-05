#include <complex>
#include <iostream>
#include <cmath>
#include <cassert>
#include <vector>

#include "Matrix.h"

using namespace std;

Num sign( int n )
{
	return n%2 ? -1.0 : 1.0;
}

Matrix mm_e(  Num f, Num a, Num b1, Num b2, 
	      Num l1,Num l2,unsigned N1, unsigned N2)
{

/*
// mm_e      [S, kz1, kz2] = mm_e(f,a,b1,b2,l1,l2,N1,N2) -> Calculates the 
//           S-parameters of a centered e-plane step discontinuity in a 
//           rectangular waveguide with ideal transmission lines cascaded to
//           the discontinuity.
		//
//           f = frequency [Hz]
//           a = waveguide width [m]
//           b1 = waveguide I height [m]
//           b2 = waveguide II height [m] (b2>b1)
//           l1 = waveguide I length [m]
//           l2 = waveguide II length [m]
//           N1 = number of (even) modes to use in waveguide I
//           N2 = number of (even) modes to use in waveguide II

//           Author: R. Lehmensiek, 02/99.
*/

	int i,j;
	
	int im,in;
	Num m,n;
	int row,col;
	
	Num eps0 = 8.85418782e-12;
	Num mu0 = M_PI*4e-7;
	Num c = 1.0/sqrt(mu0*eps0);

	Num cc = (b2-b1)/2.0;
	Num dd = (b2+b1)/2.0;

	Matrix n1 = Matrix::range( 0,N1-1 ) * 2.0;
	Matrix n2 = Matrix::range( 0,N2-1 ) * 2.0;

	Num k_2 = square((2.0*M_PI*f)/c);
	Num kx = M_PI/a;
	
	Matrix ky1 = n1*(M_PI/b1);
	Matrix kc1_2 = square(kx)+square(ky1);
	
	Matrix tmp2 = (k_2-kc1_2);
	Matrix kz1 = sqrt(tmp2);
	
	for ( i=1;i<=kc1_2.length();i++ )
		if ( k_2 < kc1_2(i).real() )
			kz1(i) = -kz1(i);

	Matrix ky2 = n2*(M_PI/b2);
	Matrix kc2_2 = square(kx)+square(ky2);
	Matrix kz2 = sqrt(k_2-kc2_2);

	for ( i=1;i<=kc2_2.length();i++ )
		if ( k_2 < kc2_2(i).real() )
			kz2(i) = -kz2(i);
	
	Matrix P = Matrix::zeros(N1,N1);
	for ( i=1;i<=kc1_2.length();i++ )
		if ( k_2 < kc1_2(i).real() )
			P(i,i) = complex<Num>(0.0,1.0);
		else
			P(i,i) = 1.0;

	Matrix Qb = Matrix::zeros(N2,N2);
	for ( i=1;i<=kc2_2.length();i++ )
		if ( k_2 < kc2_2(i).real() )
			Qb(i,i) = complex<Num>(0.0,1.0);
		else
			Qb(i,i) = 1.0;

	Matrix Cab = Matrix::zeros(N2,N1);

	Cab(1,1) = b1*(cos(ky1(1)*cc)-sin(ky1(1)*cc));

	for ( im=1;im<=n2.length();im++ )
	{
		m = n2(im).real();
		for ( in=1;in<=n1.length();in++ )
		{
			n = n1(in).real();
			row = (int)(m/2+1);
			col = (int)(n/2+1);
			if ( m != 0.0 )
				if ( ky1(col)==ky2(row) )
					Cab(row,col) = cos(ky1(col)*cc)*b1/2.0+(sign((int)n)*sin(ky2(row)*dd)-sin(ky2(row)*cc))/(2.0*(ky1(col)+ky2(row)));
				else
					Cab(row,col) = (sign((int)n)*sin(ky2(row)*dd)-sin(ky2(row)*cc))*(1.0 /(2.0*(ky1(col)+ky2(row)))-1.0/(2.0*(ky1(col)-ky2(row))));
			Cab(row,col) = -((square(kx)-k_2)/conj(kz2(row)))/sqrt(abs((square(kx)-k_2)/conj(kz1(col)))*abs((square(kx)-k_2)/conj(kz2(row)))*b1*b2)*Cab(row,col);
			if ( m>0 )
				Cab(row,col) = Cab(row,col)*sqrt(2.0);
			if (n>0)
				Cab(row,col) = Cab(row,col)*sqrt(2.0);
		}
	}
	
	Matrix Rab = conjugate(P*Cab.transpose());
	Matrix Tab = Qb*Cab;

	Matrix I = Matrix::identity(N2);
	LUDecomposition tmp(Tab*Rab+I);
	
	Matrix S21 = 2.0*tmp.backslash(Tab);
	Matrix S22 = tmp.backslash(Tab*Rab-I);
	Matrix S12 = Rab*(I-S22);

	I = Matrix::identity(N1);
	Matrix S11 = I-Rab*S21;

	Matrix D1 = exp(kz1*complex<Num>(0,-l1)).diagonalize();
	Matrix D2 = exp(kz2*complex<Num>(0,-l2)).diagonalize();

	return   Matrix::rowCat( Matrix::colCat( D1*S11*D1, D1*S12*D2 ),
				 Matrix::colCat( D2*S21*D1, D2*S22*D2 ) );
}

Matrix cascade( Matrix A, Matrix B, int m )
{
/*
// cascade   [S] = cascade(A,B,m) -> Cascades scattering matrices A and B.
//           m = size of matrix A22.
//           Assumes ports 1 to m of B are cascaded to ports N-m to N of A. N=rows(A)

//           Author: R. Lehmensiek, 01/99.
*/

	int NA = A.size();
	int n = NA-m;
	
	Matrix A11 = A.slice( 1,n,1,n );
	Matrix A12 = A.slice( 1,n,n+1,NA );
	Matrix A21 = A.slice( n+1,NA,1,n );
	Matrix A22 = A.slice( n+1,NA,n+1,NA );

	int NB = B.size();

	Matrix B11 = B.slice( 1,m,1,m );
	Matrix B12 = B.slice( 1,m,m+1,NB );
	Matrix B21 = B.slice( m+1,NB,1,m );
	Matrix B22 = B.slice( m+1,NB,m+1,NB );

	LUDecomposition W( Matrix::identity(m) - A22 * B11);

	Matrix S11 = A11 + A12 * B11 * W.backslash(A21);
	Matrix S12 = A12 * (B11 * W.backslash( A22 ) + Matrix::identity(m)) * B12;
	Matrix S21 = B21 * W.backslash( A21 );
	Matrix S22 = B22 + B21 * W.backslash( A22 ) * B12;

	return Matrix::rowCat( Matrix::colCat( S11, S12 ), Matrix::colCat( S21, S22) );
}

Matrix wgcapstp( Num f, Num a, Num b, Num b1, Num w, unsigned N1=20, unsigned N2=20)
{

/*
// wgcapstp  [S] = wgcapstp(f,a,b,b1,w,N1,N2), Calculates the S-parameters of a centered e-plane
//           step discontinuity in a rectangular waveguide.
//
//           Input:
//              f   = frequency [Hz]
//              a   = waveguide width [m]
//              b   = waveguide height [m]
//              b1  = gap height [m] (b>b1)
//              w   = step length [m]
//              N1  = number of (even) modes to use in waveguide (Default = 20)
//              N2  = number of (even) modes to use in step (Default = 20)
//
//           Output:
//              S   = S-parameters

//           Author : R. Lehmensiek, 08/00.
*/

	Num l2 = -w/2.0;

	Matrix S1 = mm_e(f,a,b1,b,w/2.0,l2,N1,N2);
	Matrix S2 = Matrix::rowCat(
		Matrix::colCat(
			S1.slice(N1+1,N1+N2,N1+1,N1+N2),
			S1.slice(N1+1,N1+N2,1,N1)),
		Matrix::colCat(
			S1.slice(1,N1,N1+1,N1+N2),
			S1.slice(1,N1,1,N1) ) );
	Matrix S = cascade(S2,S1,N1);
	Matrix ret = Matrix(1,4);

	ret(1,1) = S(1,1);
	ret(1,2) = S(1,N2+1);
	ret(1,3) = S(N2+1,1);
	ret(1,4) = S(N2+1,N2+1);

	return ret;
}

int main( int argc, char* argv[] )
{
	if ( argc < 4 )
	{
		cout << "USAGE : ./step <frequency> <gap height> <step length> [<options>]" << endl;
		cout << endl;
		cout << "  VALID RANGES (when a and b options on default values): " << endl;
		cout << "      frequency (in Ghz)   [7-13]" << endl;
		cout << "      gap height (in mm)   [2-8]" << endl;
		cout << "      step length (in mm)  [0.5-5]" << endl;
		cout << "  OPTIONS (defaults in square brackets):" << endl;
		cout << "      -a=<waveguide width>            [22.86e-3]" << endl;
		cout << "      -b=<waveguide height>           [10.16e-3]" << endl;
		cout << "      -N1=<# of modes for waveguide>  [40]" << endl;
		cout << "      -N2=<# of modes for step>       [40]" << endl;
		cout << endl;
		return 1;
	}
		
	Num f = atof( argv[1] ) * 1e9;
	Num h = atof( argv[2] ) * 1e-3;
	Num w = atof( argv[3] ) * 1e-3;
	Num a = 22.86e-3;
	Num b = 10.16e-3;
	int N1 = 40;
	int N2 = 40;
	int i;

	for ( i=4;i<argc;i++ )
	{
		char* p;
		if ( argv[i][0] != '-' || (p = strchr(argv[i],'=')) == NULL )
		{
			cout << "[W] Invalid option : " << argv[i] << endl;
			continue;
		}
		
		*p = '\0';
		++p;
		
		if ( strcmp( &argv[i][1], "a" ) == 0 )
			a = atof(p);
		if ( strcmp( &argv[i][1], "b" ) == 0 )
			b = atof(p);
		if ( strcmp( &argv[i][1], "N1" ) == 0 )
			N1 = atoi(p);
		if ( strcmp( &argv[i][1], "N2" ) == 0 )
			N2 = atoi(p);
	}
	
	Matrix S = wgcapstp( f,a,b,h,w,N1,N2 );
	
	for ( i=1;i<=4;i++ )
		cout << S(i).real() << '\t' << S(i).imag() << endl;

	return 0;
}
