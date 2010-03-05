function outpoints = ExponentialTaperedTML(points)

%  Source:
%  Robust Parametric Macromodeling using Multivariate Orthonormal Vector
%  Fitting
%  D. Deschrijver, T. Dhaene, D. De Zutter,
%  IEEE Transactions on Microwave Theory and Techniques,
%  Vol. 56, No. 7, pp. 1661-1667, July 2008.

% should the frequency be auto-sampled?
autoSampling = false;

if(autoSampling)
  % we wish to cover a frequency range of 1 kHz to 3 GHz
  % so lets create a sweep in log10 spce to cover this large range
  f = logspace(3,9.4771212,30);
else
  % no auto sampling use the freq requested by the toolbox
  f = points(:,3);

  % The toolbox performs its sample selection in Ghz so change to Hz
  f = f * 1e9;
end

c0=2.998*1e8;

for k=1:length(f)
	for j = 1 : size(points, 1)
	  eps_r = points(j,2);
	  beta(k,j)=2*pi*f(k)/c0*sqrt(eps_r);
    end
end


ZL=0.6931;

outpoints = zeros(0,4);
for j = 1 : size(points, 1)
	lung = points(j,1);
	eps_r = points(j,2);
	for k=1:length(f)
		out = 0.5*exp(-i*beta(k,j)*lung)*ZL*sin(beta(k,j)*lung)/(beta(k,j)*lung);
		% return the freq in Ghz so the toolbox is not confused		
		outpoints = [outpoints ; lung eps_r (f(k)/1e9) real(out) imag(out)]; 
	end
end

% if no auto sampling only return the outputs, not the inputs
if(autoSampling == false)
  outpoints = outpoints(:,[4 5]);
end
