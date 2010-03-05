function out = s11_stp(f,h,l)

% Our parameter ranges: ...
%   frequency (in Ghz)   [7-13]
%   gap height (in mm)   [2-8]
%   step length (in mm)  [0.5-5]

f = ((f+1)/2*(13-7)+7)*1e9;
h = ((h+1)/2*(8-2)+2)*1e-3;
l = ((l+1)/2*(5-.5)+.5)*1e-3;

S = Lehmensiek_wgcapstp(f,22.86e-3,10.16e-3,h,l,40,40);
unsorted = [real(S) imag(S)];
out = unsorted([1 5 2 6 3 7 4 8]);
