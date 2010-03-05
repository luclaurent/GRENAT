#include "Matrix.h"
#include <vector>
#include <cstring>
#include <cstdlib>


Matrix wgindps2( Num f, Num a, Num d, Num a0, int M=1000, Num Z0=1.0)
{
	// % wgindps2  S = wgindps2(f,a,d,a0,M,Z0), Calculates the
	// % S-parameters of two centered inductive post 
	// %           discontinuities in a rectangular waveguide.
	// %
	// %           Input:
	// %              f   = frequency [Hz]
	// %              a   = waveguide width [m]
	// %              d   = post diameter [m]
	// %              a0  = distance between posts [m]
	// %              M   = number of current lines (Default = 500)
	// %              Z0  = characteristic impedance (Default = 1)
	// %
	// %           Output:
	// %              S   = S-parameters
	// 
	// %           Authors: P. Meyer
	// %                    R. Lehmensiek, 08/2000.

	double eps0 = 8.85418782e-12;     // [C^2/Nm^2] free space permittivity
	double mu0 = M_PI*4e-7;           // [N/A^2] free space permeability
	double eta = sqrt(mu0/eps0);      // [Nm/s] intrinsic impedance
	double c = 1/sqrt(mu0*eps0);      // [m/s] speed of light
	double k = (2*M_PI*f)*sqrt(mu0*eps0);

	int N = (int) round(50*M_PI*d/(c/f));     // 50 sources per wavelength circumference
	if ( N < 20 )
		N = 20;
	
	Matrix Na = Matrix::range(0,N-1);
	Matrix I = Matrix::ones(N,1);

	Matrix tmp = 2*M_PI*Na/N;
	Matrix t1 = d*realsin(tmp);
	Matrix t2 = d*realcos(tmp);
	a0 = (a-a0)/2;

	Matrix xs = Matrix::rowCat(a0+0.45*t1, (a-a0)+0.45*t1);
	Matrix zs = Matrix::rowCat(0.45*t2, 0.45*t2); 
	
	Matrix xo = Matrix::rowCat(a0*I+0.5*t1, (a-a0)*I+0.5*t1);
	Matrix zo = Matrix::rowCat(0.5*t2, 0.5*t2);
	Matrix m = Matrix::range(1,M).transpose();
	Matrix kz = Matrix::colCat( sqrt(square(k)-square(M_PI/a)),
		-sqrt(square(k)-square((Matrix::range(2,M).transpose())*M_PI/a)));

	N = xs.length();
	Matrix Zg(N,0);

	complex<Num> j(0.0,1.0);
	
	Matrix Vinc = Matrix::multiply( -realsin(M_PI*xo/a), exp(-j*kz(1)*zo) );
	I = Matrix::ones(N,1);
	for ( int l=1;l<=N;l++ )
	{
		Matrix t1 = Matrix::divide( 
			exp(-j*abs(zo(l)-zs)*kz), (I*kz) );
		Matrix t2 = Matrix::divide(
			exp(-M_PI/a*abs(zo(l)-zs)*m), (I*(m*M_PI/a)) );
		Matrix t3 = Matrix::multiply( 
			sin(M_PI/a*xs*m), (I*sin(m*M_PI*xo(l)/a)));
		t3 = ((t1-t2)*t3.hermite()).diag();
  
		t1 = 1-exp(j*(M_PI/a)*(abs(xo(l)+xs)+j*abs(zo(l)-zs)));
		t2 = 1-exp(j*(M_PI/a)*(abs(xo(l)-xs)+j*abs(zo(l)-zs)));
 
		Zg = Matrix::colCat( Zg, 
			-(0.5*k*eta/M_PI)*
			(real(log(Matrix::divide(t1,t2))))
			-(k*eta/a)*t3 );
	}

	Matrix Ig = LUDecomposition(Zg.transpose()).backslash(Vinc);

	tmp = Matrix::multiply((k*eta*Ig)/(kz(1)*a),
			       	sin(M_PI*xs/a));
	complex<Num> S11 = sum(Matrix::multiply(-tmp, exp(-j*kz(1)*zs)));
	complex<Num> S21 = 1.0-sum(Matrix::multiply(tmp,exp(j*kz(1)*zs)));

	Matrix S(2,2);
	S(1,1) = S(2,2) = S11;
	S(1,2) = S(2,1) = S21;
	return S;
}

Matrix inductive_posts( Num freq, Num gap, Num diam )
{
	// % s21_pst   s21 = s21_pst(par), Calculates the S-parameters of two
	// % centered inductive posts in a rectangular waveguide. 
	// %           Same as wgindps2.m, with input variables manipulated
	// %           for adaptive sampling algorithm. 
	// %
	// %           Input:
	// %              par(1) = [GHz] frequency, f
	// %              par(2) = [mm] gap height, h
	// %
	// %           Output:
	// %              s21    = transmission coefficient
	// 
	// %           Also uses: wgindps2.m.
	// 
	// %           Author: R. Lehmensiek, 08/1999.
	// %		Parametrization modified 1/2005 by W. Hendrickx
	
	double f = freq*1e9;
	double w = gap*1e-3;
	double d = diam*1e-3; //% was fixed at 2e-3 before
	
	return wgindps2(f,22.86e-3,d,w);
}

Num scale(Num v, Num L, Num R) {
	v = (v+1.0)/2.0;
	v *= (R-L);
	return v + L;
}

int main( int argc, char* argv[] )
{
	if ( argc < 4 )
	{
		cout << "USAGE : ./InductivePosts <frequency> <distance between posts> <post diameter> [<options>]" << endl;
		cout << endl;
		cout << "  VALID RANGES (when a option on default values): " << endl;
		cout << "      frequency (in Ghz)   [7-13]" << endl;
		cout << "      distance (in mm)     [4-18]" << endl;
		cout << "      diameter (in mm)     [1-5]" << endl;
		cout << "  For use in the M3 toolbox, all parameters are rescaled" << endl;
		cout << "  to the [-1,1] interval (so -1 means 7GHz, 1 means 13GHz)" << endl;
		cout << "  Use the -noscale option to provide parameters in the real range" << endl;
		cout << "  OPTIONS (defaults in square brackets):" << endl;
		cout << "      -a=<waveguide width>            [22.86e-3]" << endl;
		cout << "      -M=<# of current lines>         [500]" << endl;
		cout << "      -Z0=<characteristic impedance>  [40]" << endl;
		cout << "      -noscale" << endl;
		cout << endl;
		return 1;
	}

	// scale the parameters to the correct range from [-1,1]
	double f = atof( argv[1] );
	double a0 = atof( argv[2] );
	double d = atof( argv[3] );
	Num a = 22.86e-3;
	int M = 500;
	Num Z0 = 1.0;

	int i;
	bool noscale = false;

	for ( i=4;i<argc;i++ )
	{
		char* p;
		if ( argv[i][0] != '-' )
		{
			cout << "[W] Invalid option : " << argv[i] << endl;
			continue;
		}
		if ( (p = strchr(argv[i],'=')) == NULL )
		{
			if ( strcmp( argv[i], "-noscale" ) == 0 )
				noscale = true;
		}
		else
		{
			*p = '\0';
			++p;
	
			if ( strcmp( &argv[i][1], "a" ) == 0 )
				a = atof(p);
			else if ( strcmp( &argv[i][1], "Z0" ) == 0 )
				Z0 = atof(p);
			else if ( strcmp( &argv[i][1], "M" ) == 0 )
				M = atoi(p);
			else
				cout << "[W] Invalid option : " << argv[i] << endl;
		}
	}

	if ( !noscale ) {
		f  = scale( f,  7, 13 );
		a0 = scale( a0, 4, 18 );
		d  = scale( d,  1,  5 );
	}
	
	// multiply by stuff
	f *= 1e9;
	a0 *= 1e-3;
	d *= 1e-3;	
	
	Matrix S = wgindps2( f,a,d,a0,M,Z0 );

	for ( i=1;i<=4;i++ ) {
		printf("%.25lf\n", S(i).real());
		printf("%.25lf\n", S(i).imag());
	}
	
	return 0;
}
