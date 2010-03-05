% From Gary Wang rbf_hdmr paper
% but origin is in matlab optimization toolbox (large-scale optimization)
% Example: Nonlinear Minimization with Gradient and Hessian
function out = matlab_optim1(varargin)

	d1 = 1:nargin-1;
	x = cell2mat( varargin );
	mat = x(:,d1).^(2.*x(:,d1+1)+2) + ...
			x(:,d1+1).^(2.*x(:,d1+1)+2);
	
	out = sum( mat, 2 );

end