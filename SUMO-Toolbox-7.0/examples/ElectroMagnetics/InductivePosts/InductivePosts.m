function out = s21_pst(f,w,h)

%      frequency (in Ghz)   [7-13]
%      distance (in mm)     [4-18]
%      diameter (in mm)     [1-5]

f = ((f+1)/2*(13-7)+7)*1e+9;
w = ((w+1)/2*(18-4)+4)*1e-3;
h = ((h+1)/2*( 5-1)+1)*1e-3;

S = Lehmensiek_wgindps2(f,22.86e-3,h,w,500,1);

unsorted = [real(S) imag(S)];
out = unsorted([1 5 2 6 3 7 4 8]);
