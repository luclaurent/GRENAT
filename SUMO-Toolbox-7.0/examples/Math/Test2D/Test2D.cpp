#include <math.h>
#include <cstdio>
#include <cassert>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

using namespace std;
/* Gamma function in double precision */

void sleep(time_t delay) {
	time_t t0, t1;
	time(&t0);
	do {
		time( &t1 );
	}
	while (( t1 - t0 ) < delay );
}

int main(int argc, char ** argv) {
	assert( argc == 3 );

	sleep(60);

	// read parameters
	double x = atof( argv[1] );
	double y = atof( argv[2] );
	
	double f =((x+1.0f)*3.0f + exp(3.5f * x) * sin(x * 4.0f * 3.141592f)) * y * y;

	// write f to stdout, forwarded to correct file
	printf("%.25lf\n", f);
	
	return 0;
}

