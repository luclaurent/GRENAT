function S = wgindps2(f,a,d,a0,M,Z0)

% wgindps2  S = wgindps2(f,a,d,a0,M,Z0), Calculates the
% S-parameters of two centered inductive post 
%           discontinuities in a rectangular waveguide.
%
%           Input:
%              f   = frequency [Hz]
%              a   = waveguide width [m]
%              d   = post diameter [m]
%              a0  = distance between posts [m]
%              M   = number of current lines (Default = 500)
%              Z0  = characteristic impedance (Default = 1)
%
%           Output:
%              S   = S-parameters

%           Authors: P. Meyer
%                    R. Lehmensiek, 08/2000.

if nargin<4, error(['Error:  wgindps2(f,a,d,a0,M,Z0) - Not enough' ...
		    ' input parameters']) 
elseif nargin<5, M = 500; Z0 = 1;
elseif nargin<6, Z0 = 1;
end

eps0 = 8.85418782e-12;     % [C^2/Nm^2] free space permittivity
mu0 = pi*4e-7;             % [N/A^2] free space permeability
eta = sqrt(mu0/eps0);      % [Nm/s] intrinsic impedance
c = 1/sqrt(mu0*eps0);      % [m/s] speed of light
k = (2*pi*f)*sqrt(mu0*eps0);

N = round(50*pi*d/(c/f));      % 50 sources per wavelength circumference
if N < 20, N = 20; end;        % Min 20 sources per post
Na = [0:N-1]';
I = ones(size(Na));

tmp = 2*pi*Na/N;
t1 = d*sin(tmp);
t2 = d*cos(tmp);

a0 = (a-a0)/2;

xs = [a0*I+0.45*t1; (a-a0)*I+0.45*t1];
zs = [0.45*t2; 0.45*t2]; 
xo = [a0*I+0.5*t1; (a-a0)*I+0.5*t1];
zo = [0.5*t2; 0.5*t2];

m = [1:M];
kz(m) = [sqrt(k^2-(pi/a)^2) -sqrt(k^2-([2:M]*pi/a).^2)];

N = length(xs);
Zg = zeros(N);

Vinc = -sin(pi*xo/a).*exp(-j*kz(1)*zo);
I = ones(N,1);
for l=1:N
  t1 = exp(-j*abs(zo(l)-zs)*kz)./(I*kz);
  t2 = exp(-pi/a*abs(zo(l)-zs)*m)./(I*(m*pi/a));
  t3 = sin(pi/a*xs*m).*(I*sin(m*pi*xo(l)/a));
  t3 = diag((t1-t2)*t3');

  t1 = 1-exp(j*(pi/a)*(abs(xo(l)+xs)+j*abs(zo(l)-zs)));
  t2 = 1-exp(j*(pi/a)*(abs(xo(l)-xs)+j*abs(zo(l)-zs)));
  
  Zg(:,l) = -(0.5*k*eta/pi)*(real(log(t1./t2)))-(k*eta/a)*t3;
end

Ig = inv(Zg.')*Vinc;

tmp = (k*eta*Ig/(kz(1)*a)).*sin(pi*xs/a);
S11 = sum(-tmp.*exp(-j*kz(1)*zs));
S21 = 1-sum(tmp.*exp(j*kz(1)*zs));

S = [S11 S21 S21 S11];
