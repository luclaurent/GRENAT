#ifndef MATRIX_H
#define MATRIX_H

#include <iostream>
#include <complex>
#include <cassert>
#include <vector>
using namespace std;

typedef double Num;

class Matrix;
Matrix conjugate( const Matrix& x );

class Matrix
{
	private:
		complex<Num>* data;
		int nrows, ncols;
		
	public:
		Matrix( int x=1, int y=1, Num z=0.0 )
			: nrows(x), ncols(y)
		{
			data = new complex<Num>[x*y];
			for (int i=0;i<x*y;i++)
				data[i] = z;
		}
		
 		Matrix( Num x )
 		{
 			nrows = ncols = 1;
 			data = new complex<Num>[1];
 			data[0] = x;
 		}

		~Matrix( void )
		{
			delete[] data;
		}
		
		Matrix( const Matrix& x )
		{
			data = new complex<Num>[x.length()];
			nrows = x.rows();
			ncols = x.cols();
			for ( int i=1;i<=x.length();i++ )
				(*this)(i) = x(i);
		}
			
		const Matrix& operator=( const Matrix& x )
		{
			delete[] data;
			data = new complex<Num>[x.length()];
			nrows = x.rows();
			ncols = x.cols();
			for ( int i=1;i<=x.length();i++ )
				(*this)(i) = x(i);
			return *this;
		}
		
		int rows( void ) const { return nrows; }
		int cols( void ) const { return ncols; }
		int length( void ) const { return nrows*ncols; }
		int size( void ) const { assert(nrows==ncols); return nrows; }
		
		static Matrix zeros( int x, int y )
		{
			return Matrix(x,y);
		}
		
		static Matrix zeros( int x )
		{
			return Matrix(x,x);
		}
		
		static Matrix ones( int x, int y )
		{
			return Matrix(x,y,1.0);
		}
		
		static Matrix ones( int x )
		{
			return Matrix(x,x,1.0);
		}
		
		static Matrix identity( int n )
		{
			assert( n>=0 );
			Matrix ret(n,n);
			for ( int i=1;i<=n;i++ )
				ret(i,i) = 1.0;
			return ret;
		}
		
		static Matrix range( Num start, Num end, Num step=1.0 )
		{
			assert( (end-start) * step > 0 );
			int n = (int)((1.0+1e-20)*(end-start) / step) + 1;
			Matrix ret = Matrix( n,1 );
			Num x = start;
			for ( int i=1;i<=n;i++,x+=step )
				ret(i) = x;
			return ret;
		}
		
		static Matrix rowCat( const Matrix& a, const Matrix& b )
		{
			int i,j;
			assert( a.cols() == b.cols() );
			Matrix ret( a.rows()+b.rows(), a.cols() );
			for ( i=1;i<=a.rows();i++ )
				for ( j=1;j<=a.cols();j++ )
					ret(i,j) = a(i,j);
			for ( i=1;i<=b.rows();i++ )
				for ( j=1;j<=b.cols();j++ )
					ret(i+a.rows(),j) = b(i,j);
			return ret;
		}
			
		static Matrix colCat( const Matrix& a, const Matrix& b )
		{
			int i;
			assert( a.rows() == b.rows() );
			Matrix ret( a.rows(), a.cols()+b.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i);
			for ( i=1;i<=b.length();i++ )
					ret(i+a.length()) = b(i);
			return ret;
		}
		
		complex<Num>& operator() (int i)
		{
			assert( i>0 && i <= nrows*ncols );
			return data[i-1];
		}
		
		const complex<Num>& operator() (int i) const
		{
			assert( i>0 && i <= nrows*ncols );
			return data[i-1];
		}

		complex<Num>& operator() (int r, int c)
		{
			assert( r>0 && r<=nrows );
			assert( c>0 && c<=ncols );
			return data[(c-1)*nrows+r-1];
		}

		const complex<Num>& operator() (int r, int c) const
		{
			assert( r>0 && r<=nrows );
			assert( c>0 && c<=ncols );
			return data[(c-1)*nrows+r-1];
		}
		
		friend Matrix operator*( const Matrix& a, Num b )
		{
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i) * b;
			return ret;
		}
		
		friend Matrix operator*( const Matrix& a, const complex<Num>& b )
		{
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i) * b;
			return ret;
		}
		
		friend Matrix operator/( const complex<Num>& a, const Matrix& b )
		{
			int i;
			Matrix ret( b.rows(), b.cols() );
			for ( i=1;i<=b.length();i++ )
				ret(i) = a / b(i);
			return ret;
		}
		
		friend Matrix operator/( Num a, const Matrix& b )
		{
			int i;
			Matrix ret( b.rows(), b.cols() );
			for ( i=1;i<=b.length();i++ )
				ret(i) = a / b(i);
			return ret;
		}
		
		Matrix operator/( const complex<Num>& a )
		{
			int i;
			Matrix ret( rows(), cols() );
			for ( i=1;i<=length();i++ )
				ret(i) = (*this)(i) / a;
			return ret;
		}
		
		Matrix operator/( const Num a )
		{
			return *this / complex<Num>(a);
		}
		friend Matrix operator*( const complex<Num>& a, const Matrix& b )
		{
			return b*a;
		}
		friend Matrix operator*( Num a, const Matrix& b )
		{
			return b*a;
		}
		
		friend Matrix operator/( const Matrix& a, Num b )
		{
			assert( b!=0 );
			return a*(1.0/b);
		}
		
		friend Matrix operator*( const Matrix& a, const Matrix& b )
		{
			int i,j,k;
			int n = a.rows();
			int m = b.cols();
			assert( a.cols() == b.rows() );
			Matrix ret(n,m);
			complex<Num> sum;
			for ( i=1;i<=n;i++ )
				for (j=1;j<=m;j++ )
				{
					for ( sum=0.0,k=1;k<=a.cols();k++ )
						sum += a(i,k) * b(k,j);
					ret(i,j) = sum;
				}
			return ret;
		}

		friend Matrix operator+( const Matrix& a, complex<Num> b )
		{
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i) + b;
			return ret;
		}
		
		friend Matrix operator+( const Matrix& a, Num b )
		{
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i) + b;
			return ret;
		}

		friend Matrix operator+( complex<Num> a, const Matrix& b )
		{
			return b+a;
		}
		
		friend Matrix operator+( Num a, const Matrix& b )
		{
			return b+a;
		}

		friend Matrix operator+( const Matrix& a, const Matrix& b )
		{
			int i,j;
			int n = a.rows();
			int m = a.cols();
			assert( a.cols() == b.cols() );
			assert( a.rows() == b.rows() );
			Matrix ret(n,m);
			for ( i=1;i<=n;i++ )
				for (j=1;j<=m;j++ )
					ret(i,j) = a(i,j)+b(i,j);
			return ret;
		}

		Matrix operator-( void )
		{
			Matrix ret( rows(), cols() );
			for ( int i=1;i<=length();i++ )
				if ( (*this)(i).imag() == 0.0 )
					ret(i) = -(*this)(i).real();
				else
					ret(i) = -(*this)(i);
			return ret;
		}
		
		friend Matrix operator-( const Matrix& a, const complex<Num>& b )
		{
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i) - b;
			return ret;
		}
		
		friend Matrix operator-( const Matrix& a, Num b )
		{ 
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				ret(i) = a(i) - b;
			return ret;
		}

		friend Matrix operator-( const complex<Num>& b, const Matrix& a )
		{
			int i;
			Matrix ret( a.rows(), a.cols() );
			for ( i=1;i<=a.length();i++ )
				if ( a(i).imag() == 0.0 )
					ret(i) = b - a(i).real();
				else
					ret(i) = b - a(i);
			return ret;
		}
		
		friend Matrix operator-( Num b, const Matrix& a )
		{
			return complex<Num>(b) - a;
		}
		
		friend Matrix operator-( const Matrix& a, const Matrix& b )
		{
			int i,j;
			int n = a.rows();
			int m = a.cols();
			assert( a.cols() == b.cols() );
			assert( a.rows() == b.rows() );
			Matrix ret(n,m);
			for ( i=1;i<=n;i++ )
				for (j=1;j<=m;j++ )
					ret(i,j) = a(i,j)-b(i,j);
			return ret;
		}

		
		Matrix transpose( void )
		{
			int i,j;
			Matrix ret( ncols, nrows );
			for ( i=1;i<=nrows;i++ )
				for (j=1;j<=ncols;j++ )
					ret(j,i) = (*this)(i,j);
			return ret;
		}
		
		Matrix hermite( void )
		{
			return conjugate(transpose());
		}
		
		Matrix slice( int a, int b, int c, int d ) const
		{
			int i,j;
			assert( a <= b );
			assert( c <= d );
			Matrix ret( b-a+1, d-c+1 );
			for ( i=a;i<=b;i++ )
				for ( j=c;j<=d;j++ )
					ret(i-a+1,j-c+1) = (*this)(i,j);
			return ret;
		}
		
		Matrix diag( void )
		{
			if ( rows() == 1 || cols() == 1 )
				return diagonalize();
			
			assert( rows() == cols() );
			Matrix ret = Matrix( rows(), 1 );
			for ( int i=1;i<=rows();i++ )
				ret(i) = (*this)(i,i);
			return ret;
		}
		
		Matrix diagonalize( void )
		{
			Matrix ret( length(), length() );
			for ( int i=1;i<=length();i++ )
				ret(i,i) = (*this)(i);
			return ret;
		}
		
		friend ostream& operator<<( ostream& out, const Matrix& x )
		{
			int i,j;
			
			for ( i=1;i<=x.rows();i++ )
			{
				cout << "[[";
				for ( j=1;j<=x.cols();j++ )
					cout << x(i,j) << '\t';
				cout << "]]" << endl;
			}
			cout << endl;
			
			return out;
		}
		
		static Matrix multiply( const Matrix& a, const Matrix& b )
		{
		//	cout << "A : " << a << "B : " << b << endl;
			assert( a.rows() == b.rows() && a.cols() == b.cols() );
			Matrix ret( a.rows(), a.cols() );
			for ( int i=1;i<=a.length();i++ )
				ret(i) = a(i) * b(i);
			return ret;
		}
					
		static Matrix divide( const Matrix& a, const Matrix& b )
		{
			assert( a.rows() == b.rows() && a.cols() == b.cols() );
			Matrix ret( a.rows(), a.cols() );
			for ( int i=1;i<=a.length();i++ )
				ret(i) = a(i) / b(i);
			return ret;
		}
		
		double maxAbs( void ) const
		{
			double max = 0.0;
			for ( int i=1;i<=length();i++ )
				if ( max < abs((*this)(i)) )
					max = abs( (*this)(i) );
			return max;
		}
};

class LUDecomposition
{
	private:
		Matrix A;
		Matrix LU;
		vector<int> permutation;
		int size;
		bool success;
		
	public:
		LUDecomposition( const Matrix& x )
			: size(x.size()),success(true),A(x),LU(x)
		{
			permutation = vector<int>( size+1, 0 );
			
			const int n = size;
			int i,imax=-1,j,k;
			complex<Num> d = Num(1.0);
			complex<Num> dum,sum,temp;
			complex<Num> big;
		
			Matrix vv(1,n);
			
			for (i=1;i<=n;i++) {
				big=0.0;
				for (j=1;j<=n;j++)
					if (abs(LU(i,j)) > abs(big) )
						big=LU(i,j);
				if (big == 0.0) {
					success = false;
					return;
				}
				vv(i)=1.0/big;
			}
			
			for (j=1;j<=n;j++) {
				for (i=1;i<j;i++) {
					sum=LU(i,j);
					for (k=1;k<i;k++) sum -= LU(i,k)*LU(k,j);
					LU(i,j)=sum;
				}
				big=0.0;
				for (i=j;i<=n;i++) {
					sum=LU(i,j);
					for (k=1;k<j;k++)
						sum -= LU(i,k)*LU(k,j);
					LU(i,j)=sum;
					dum=vv(i)*sum;
					if ( abs(dum) >= abs(big)) {
						big=dum;
						imax=i;
					}
				}
				
				if (j != imax) {
					for (k=1;k<=n;k++) {
						dum=LU(imax,k);
						LU(imax,k)=LU(j,k);
						LU(j,k)=dum;
					}
					d = -d;
					vv(imax)=vv(j);
				}
				
				permutation[j]=imax;
				if (LU(j,j) == 0.0)
				{
					success = false;
					return;
				}
				if (j != n) {
					dum=1.0/(LU(j,j));
					for (i=j+1;i<=n;i++) LU(i,j) *= dum;
				}
			}
		}
		
		Matrix backsubstitute( const Matrix& b )
		{
// 			cout << "BS " << b.length() << endl;
			Matrix ret( b );
			const int n = size;
			int i,ii=0,ip,j;
			complex<Num> sum;

			for (i=1;i<=n;i++) {
				ip=permutation[i];
				sum=ret(ip);
				ret(ip)=ret(i);
				if (ii)
					for (j=ii;j<=i-1;j++) sum -= LU(i,j)*ret(j);
				else if (abs(sum) == 0.0) ii=i;
				ret(i)=sum;
			}
			for (i=n;i>=1;i--) {
				sum=ret(i);
				for (j=i+1;j<=n;j++) sum -= LU(i,j)*ret(j);
				ret(i)=sum/LU(i,i);
			}
			
			return ret;
		}
		
		Matrix inverse( void )
		{
			int i;
			Matrix result( size,0 );
			for ( i=1;i<=size;i++ )
			{
				Matrix rhs( size,1 );
				rhs(i) = 1.0;
				result = Matrix::colCat( result, backsubstitute(rhs) );
			}
			return result;
		}
		
		Matrix backslash( const Matrix& b, int iter = 0 )
		{
			int i;
			assert( b.rows() == size );
			Matrix result( size,0 );
			for ( i=1;i<=b.cols();i++ )
				result = Matrix::colCat( result, 
					backsubstitute(b.slice(1,size,i,i)) );
			
			Matrix delta = A * result - b;
			if ( iter < 100 && delta.maxAbs() > .0001 )
				return result - backslash( delta, iter+1 );
			
			return result;
		}
		
};

 
template <typename T> T square( const T& x ) { return x*x; }

complex<Num> conjugate( const complex<Num>& x ) { return conj(x); }
complex<Num> realsin( const complex<Num>& x ) { return sin(x.real()); }
complex<Num> realcos( const complex<Num>& x ) { return cos(x.real()); }

#define __oper(name)                       \
Matrix name( const Matrix& x )             \
{                                          \
	Matrix ret(x.rows(),x.cols() );    \
	for ( int i=1;i<=x.length();i++ )  \
		ret(i) = name(x(i));     \
	return ret;                        \
}

__oper(square)
__oper(sqrt)
__oper(conjugate)
__oper(exp)
__oper(realsin)
__oper(realcos)
__oper(sin)
__oper(cos)
__oper(abs)
__oper(log)
__oper(real)

#undef __oper

complex<Num> sum( const Matrix& x )
{
	complex<Num> result;
	for ( int i=1;i<=x.length();i++ )
		result = result + x(i);
	return result;
}

#endif
