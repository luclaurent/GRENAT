#include <math.h>
#include <cstdio>
#include <cassert>
#include <stdlib.h>
#include <unistd.h>

using namespace std;
/* Gamma function in double precision */

double dgamma(double x)
{
    int k, n;
    double w, y;

    n = x < 1.5 ? -((int) (2.5 - x)) : (int) (x - 1.5);
    w = x - (n + 2);
    y = ((((((((((((-1.99542863674e-7 * w + 1.337767384067e-6) * w - 
        2.591225267689e-6) * w - 1.7545539395205e-5) * w + 
        1.45596568617526e-4) * w - 3.60837876648255e-4) * w - 
        8.04329819255744e-4) * w + 0.008023273027855346) * w - 
        0.017645244547851414) * w - 0.024552490005641278) * w + 
        0.19109110138763841) * w - 0.233093736421782878) * w - 
        0.422784335098466784) * w + 0.99999999999999999;
    if (n > 0) {
        w = x - 1;
        for (k = 2; k <= n; k++) {
            w *= x - k;
        }
    } else {
        w = 1;
        for (k = 0; k > n; k--) {
            y *= x - k;
        }
    }
    return w / y;
}

double calculate(double x, double y){
  double f = exp(x + 2.0) / dgamma(y * 3.0) / 30.0;
  return f;
}

int main(int argc, char ** argv) {
	
	if(argc == 1){
	  // no arguments given, continue
	}else if(argc == 3){
	  // point passed on cmd line
	  double x = atof( argv[1] );
	  double y = atof( argv[2] );
	  double f = calculate(x,y);
	  
	  //sleep k minutes before returning (simulate long lasting simulation)
	  sleep(60*10);

	  printf("%.25lf\n", f);
	  return 0;
	}else{
	  printf("Invalid number of arguments\n");
	  return -1;
	}

	// read the amount of samples
	int nSamples = 0;
	if (scanf("%d", &nSamples) != 1) {
		return -1;
	}
	
	// read all samples and process them
	for (int i = 0; i < nSamples; ++i) {
		
		// read sample
		double x, y;
		scanf("%lf %lf", &x, &y);
		
		// calculate y
		double f = calculate(x,y);
		
		// write f to stdout, forwarded to correct file
		printf("%.25lf %.25lf %.25lf\n", x, y, f);
	}
		
	return 0;
}

