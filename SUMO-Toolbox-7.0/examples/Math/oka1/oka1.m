function y = oka1( x )
	%{
	 There are 2 objectives, 2 decision (x) variables. The x variables are in the ranges:
	  x[1] in [6*sin(PI/12.0), 6*sin(PI/12.0)+2*PI*cos(PI/12.0)]
	  x[2] in [-2*PI*sin(PI/12.0), 6*cos(PI/12.0)]
	%}

	x1p = cos(pi./12.0).*x(:,1) - sin(pi./12.0).*x(:,2);
	x2p = sin(pi./12.0).*x(:,1) + cos(pi./12.0).*x(:,2);

	y(:,1) = x1p;
	y(:,2) = sqrt(2*pi) - sqrt(abs(x1p)) + 2 .* (abs(x2p-3.*cos(x1p)-3).^0.33333333);
end