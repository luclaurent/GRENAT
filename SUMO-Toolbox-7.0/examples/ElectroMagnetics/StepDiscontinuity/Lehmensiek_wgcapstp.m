function [S] = wgcapstp(f,a,b,b1,w,N1,N2)

% wgcapstp  [S] = wgcapstp(f,a,b,b1,w,N1,N2), Calculates the S-parameters of a centered e-plane
%           step discontinuity in a rectangular waveguide.
%
%           Input:
%              f   = frequency [Hz]
%              a   = waveguide width [m]
%              b   = waveguide height [m]
%              b1  = gap height [m] (b>b1)
%              w   = step length [m]
%              N1  = number of (even) modes to use in waveguide (Default = 20)
%              N2  = number of (even) modes to use in step (Default = 20)
%
%           Output:
%              S   = S-parameters

%           Author : R. Lehmensiek, 08/00.

if nargin<5, error('Error:  wgcapstp(f,a,b,b1,w,N1,N2) - Not enough input parameters')
elseif nargin<6, N1 = 20; N2 = 20;
elseif nargin<7, N2 = 20;
end

l2 = -w/2;

S1 = mm_e(f,a,b1,b,w/2,l2,N1,N2);
S2 = [S1(N1+1:N1+N2,N1+1:N1+N2) S1(N1+1:N1+N2,1:N1); S1(1:N1,N1+1:N1+N2) S1(1:N1,1:N1)];
S = cascade(S2,S1,N1);
S = [S(1,1) S(1,N2+1) S(N2+1,1) S(N2+1,N2+1)];

function [S, kz1, kz2] = mm_e(f,a,b1,b2,l1,l2,N1,N2)

% mm_e      [S, kz1, kz2] = mm_e(f,a,b1,b2,l1,l2,N1,N2) -> Calculates the
%           S-parameters of a centered e-plane step discontinuity in a
%           rectangular waveguide with ideal transmission lines cascaded to
%           the discontinuity.
%
%           f = frequency [Hz]
%           a = waveguide width [m]
%           b1 = waveguide I height [m]
%           b2 = waveguide II height [m] (b2>b1)
%           l1 = waveguide I length [m]
%           l2 = waveguide II length [m]
%           N1 = number of (even) modes to use in waveguide I
%           N2 = number of (even) modes to use in waveguide II

%           Author: R. Lehmensiek, 02/1999.

eps0 = 8.85418782e-12;     % [C^2/Nm^2] free space permittivity
mu0 = pi*4e-7;             % [N/A^2] free space permeability
c = 1/sqrt(mu0*eps0);      % [m/s] speed of light

cc = (b2-b1)/2;
dd = (b2+b1)/2;
n1 = 2*[0:1:N1-1];
n2 = 2*[0:1:N2-1];

k_2 = ((2*pi*f)/c)^2;
kx = pi/a;

ky1 = n1*pi/b1;
kc1_2 = (kx)^2+(ky1).^2;
eva1 = find(k_2<kc1_2);                   % evanescent mode
kz1 = sqrt(k_2-kc1_2);                    % propagation constant
kz1(eva1) = -kz1(eva1);

ky2 = n2*pi/b2;
kc2_2 = (kx)^2+(ky2).^2;
eva2 = find(k_2<kc2_2);                   % evanescent mode
kz2 = sqrt(k_2-kc2_2);                    % propagation constant
kz2(eva2) = -kz2(eva2);

P = ones(N1,1); P(eva1) = -j*ones(length(eva1),1); P = diag(P);
Qb = ones(N2,1); Qb(eva2) = -j*ones(length(eva2),1); Qb = diag(Qb);

Cab = zeros(N2,N1);
Cab(1,1) = b1*(cos(ky1(1)*cc)-sin(ky1(1)*cc));

for m=n2
  for n=n1
    if (m~=0)
      if ky1(n/2+1)==ky2(m/2+1)
        Cab(m/2+1,n/2+1) = cos(ky1(n/2+1)*cc)*b1/2+((-1)^(n)*sin(ky2(m/2+1)*dd)-sin(ky2(m/2+1)*cc))/(2*(ky1(n/2+1)+ky2(m/2+1)));
      else
        Cab(m/2+1,n/2+1) = ((-1)^(n)*sin(ky2(m/2+1)*dd)-sin(ky2(m/2+1)*cc))*(1/(2*(ky1(n/2+1)+ky2(m/2+1)))-1/(2*(ky1(n/2+1)-ky2(m/2+1))));
      end
    end
    Cab(m/2+1,n/2+1) = -((kx^2-k_2)/conj(kz2(m/2+1)))/sqrt(abs((kx^2-k_2)/conj(kz1(n/2+1)))*abs((kx^2-k_2)/conj(kz2(m/2+1)))*b1*b2)*Cab(m/2+1,n/2+1);
    if (m>0) Cab(m/2+1,n/2+1) = Cab(m/2+1,n/2+1)*sqrt(2); end
    if (n>0) Cab(m/2+1,n/2+1) = Cab(m/2+1,n/2+1)*sqrt(2); end
  end
end

Rab = conj(inv(P)*Cab.');
Tab = inv(Qb)*Cab;

I = eye(N2);
tmp = inv(Tab*Rab+I);
S21 = 2*tmp*Tab;
S22 = tmp*(Tab*Rab-I);
S12 = Rab*(I-S22);
I = eye(N1);
S11 = I-Rab*S21;

D1 = diag(exp(-j*kz1*l1));
D2 = diag(exp(-j*kz2*l2));

S = [D1*S11*D1 D1*S12*D2; D2*S21*D1 D2*S22*D2];


function S = cascade(A,B,m)

% cascade   S = cascade(A,B,m) -> Cascades scattering matrices A and B.
%           m = size of matrix A22.
%           Assumes ports 1 to m of B are cascaded to ports N-m to N of A. N=rows(A)

%           Author: R. Lehmensiek, 01/1999.

N = size(A,1);
n = N-m;

A11 = A(1:n,1:n);
A12 = A(1:n,n+1:N);
A21 = A(n+1:N,1:n);
A22 = A(n+1:N,n+1:N);

N = size(B,1);

B11 = B(1:m,1:m);
B12 = B(1:m,m+1:N);
B21 = B(m+1:N,1:m);
B22 = B(m+1:N,m+1:N);

W = inv(eye(m)-A22*B11);

S11 = A11+A12*B11*W*A21;
S12 = A12*(B11*W*A22+eye(m))*B12;
S21 = B21*W*A21;
S22 = B22+B21*W*A22*B12;

S = [S11 S12; S21 S22];
