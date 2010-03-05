#include <cstdio>
#include <cassert>
#include <iostream>
#include <cmath>
#include <cstdlib>


using namespace std;

double sq( double x ) { return x*x; }

int main( int argc, char* argv[] )
{
	if ( !argc )
		cerr << "USAGE kotanchek <x1> ... <x5> [<noiseLevel>] [<debugFlag>]" << endl << endl;
	
	assert( argc > 5 );
	
	bool debug = argc > 7;
	int i;
	
	FILE* f = fopen( "/dev/random", "rb" );
	assert(f);
	unsigned rand;
	unsigned randmax;
	fread( (void*) &rand, sizeof(unsigned), 1, f );
	randmax = ~0;
	fclose(f);
	
	double x[5]; 
	for ( i=0;i<5;i++ )
	{
		x[i] = (1.0 + atof( argv[i+1] )) * 2.0;
		if ( debug )
			cerr << " INPUT[" << i << "] = " << x[i] << endl;
	}
		
	double output = exp( -sq( x[1] - 1.0 ) ) / ( 1.2 + sq( x[0] - 2.5 ) );
	double noise = (double) rand / (double) randmax;
	
	double noiseLevel = 0.0;	

	//If no noiseLevel is passed default to 0
	if( argc > 6){
		noiseLevel = atof( argv[6] );
	}
	
	noise = (noise * 2.0 - 1.0)* noiseLevel;	
	
	if ( debug )
	{
		cerr << "OUTPUT = " << output << endl;
		cerr << "NOISE  = " << noise << endl;
	}
	
	cout << (output+noise) << endl;
	return 0;
}
