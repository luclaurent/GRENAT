function [MatX,nbmono,MatDX,CoefDX,MatDDX,CoefDDX]=mono_15_002(X)

derprem=false;dersecond=false;
if nargout>=4;derprem=true;end
if nargout==6;dersecond=true;end

MatX=[
 ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,1).^4 ...
X(:,1).^5 ...
X(:,1).^6 ...
X(:,1).^7 ...
X(:,1).^8 ...
X(:,1).^9 ...
X(:,1).^10 ...
X(:,1).^11 ...
X(:,1).^12 ...
X(:,1).^13 ...
X(:,1).^14 ...
X(:,1).^15 ...
X(:,2) ...
X(:,1).*X(:,2) ...
X(:,1).^2.*X(:,2) ...
X(:,1).^3.*X(:,2) ...
X(:,1).^4.*X(:,2) ...
X(:,1).^5.*X(:,2) ...
X(:,1).^6.*X(:,2) ...
X(:,1).^7.*X(:,2) ...
X(:,1).^8.*X(:,2) ...
X(:,1).^9.*X(:,2) ...
X(:,1).^10.*X(:,2) ...
X(:,1).^11.*X(:,2) ...
X(:,1).^12.*X(:,2) ...
X(:,1).^13.*X(:,2) ...
X(:,1).^14.*X(:,2) ...
X(:,2).^2 ...
X(:,1).*X(:,2).^2 ...
X(:,1).^2.*X(:,2).^2 ...
X(:,1).^3.*X(:,2).^2 ...
X(:,1).^4.*X(:,2).^2 ...
X(:,1).^5.*X(:,2).^2 ...
X(:,1).^6.*X(:,2).^2 ...
X(:,1).^7.*X(:,2).^2 ...
X(:,1).^8.*X(:,2).^2 ...
X(:,1).^9.*X(:,2).^2 ...
X(:,1).^10.*X(:,2).^2 ...
X(:,1).^11.*X(:,2).^2 ...
X(:,1).^12.*X(:,2).^2 ...
X(:,1).^13.*X(:,2).^2 ...
X(:,2).^3 ...
X(:,1).*X(:,2).^3 ...
X(:,1).^2.*X(:,2).^3 ...
X(:,1).^3.*X(:,2).^3 ...
X(:,1).^4.*X(:,2).^3 ...
X(:,1).^5.*X(:,2).^3 ...
X(:,1).^6.*X(:,2).^3 ...
X(:,1).^7.*X(:,2).^3 ...
X(:,1).^8.*X(:,2).^3 ...
X(:,1).^9.*X(:,2).^3 ...
X(:,1).^10.*X(:,2).^3 ...
X(:,1).^11.*X(:,2).^3 ...
X(:,1).^12.*X(:,2).^3 ...
X(:,2).^4 ...
X(:,1).*X(:,2).^4 ...
X(:,1).^2.*X(:,2).^4 ...
X(:,1).^3.*X(:,2).^4 ...
X(:,1).^4.*X(:,2).^4 ...
X(:,1).^5.*X(:,2).^4 ...
X(:,1).^6.*X(:,2).^4 ...
X(:,1).^7.*X(:,2).^4 ...
X(:,1).^8.*X(:,2).^4 ...
X(:,1).^9.*X(:,2).^4 ...
X(:,1).^10.*X(:,2).^4 ...
X(:,1).^11.*X(:,2).^4 ...
X(:,2).^5 ...
X(:,1).*X(:,2).^5 ...
X(:,1).^2.*X(:,2).^5 ...
X(:,1).^3.*X(:,2).^5 ...
X(:,1).^4.*X(:,2).^5 ...
X(:,1).^5.*X(:,2).^5 ...
X(:,1).^6.*X(:,2).^5 ...
X(:,1).^7.*X(:,2).^5 ...
X(:,1).^8.*X(:,2).^5 ...
X(:,1).^9.*X(:,2).^5 ...
X(:,1).^10.*X(:,2).^5 ...
X(:,2).^6 ...
X(:,1).*X(:,2).^6 ...
X(:,1).^2.*X(:,2).^6 ...
X(:,1).^3.*X(:,2).^6 ...
X(:,1).^4.*X(:,2).^6 ...
X(:,1).^5.*X(:,2).^6 ...
X(:,1).^6.*X(:,2).^6 ...
X(:,1).^7.*X(:,2).^6 ...
X(:,1).^8.*X(:,2).^6 ...
X(:,1).^9.*X(:,2).^6 ...
X(:,2).^7 ...
X(:,1).*X(:,2).^7 ...
X(:,1).^2.*X(:,2).^7 ...
X(:,1).^3.*X(:,2).^7 ...
X(:,1).^4.*X(:,2).^7 ...
X(:,1).^5.*X(:,2).^7 ...
X(:,1).^6.*X(:,2).^7 ...
X(:,1).^7.*X(:,2).^7 ...
X(:,1).^8.*X(:,2).^7 ...
X(:,2).^8 ...
X(:,1).*X(:,2).^8 ...
X(:,1).^2.*X(:,2).^8 ...
X(:,1).^3.*X(:,2).^8 ...
X(:,1).^4.*X(:,2).^8 ...
X(:,1).^5.*X(:,2).^8 ...
X(:,1).^6.*X(:,2).^8 ...
X(:,1).^7.*X(:,2).^8 ...
X(:,2).^9 ...
X(:,1).*X(:,2).^9 ...
X(:,1).^2.*X(:,2).^9 ...
X(:,1).^3.*X(:,2).^9 ...
X(:,1).^4.*X(:,2).^9 ...
X(:,1).^5.*X(:,2).^9 ...
X(:,1).^6.*X(:,2).^9 ...
X(:,2).^10 ...
X(:,1).*X(:,2).^10 ...
X(:,1).^2.*X(:,2).^10 ...
X(:,1).^3.*X(:,2).^10 ...
X(:,1).^4.*X(:,2).^10 ...
X(:,1).^5.*X(:,2).^10 ...
X(:,2).^11 ...
X(:,1).*X(:,2).^11 ...
X(:,1).^2.*X(:,2).^11 ...
X(:,1).^3.*X(:,2).^11 ...
X(:,1).^4.*X(:,2).^11 ...
X(:,2).^12 ...
X(:,1).*X(:,2).^12 ...
X(:,1).^2.*X(:,2).^12 ...
X(:,1).^3.*X(:,2).^12 ...
X(:,2).^13 ...
X(:,1).*X(:,2).^13 ...
X(:,1).^2.*X(:,2).^13 ...
X(:,2).^14 ...
X(:,1).*X(:,2).^14 ...
X(:,2).^15
];
nbmono=136;

if derprem
MatDX=cell(1,size(X,2));

MatDX{1}=[
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3 ...
5.*X(:,1).^4 ...
6.*X(:,1).^5 ...
7.*X(:,1).^6 ...
8.*X(:,1).^7 ...
9.*X(:,1).^8 ...
10.*X(:,1).^9 ...
11.*X(:,1).^10 ...
12.*X(:,1).^11 ...
13.*X(:,1).^12 ...
14.*X(:,1).^13 ...
15.*X(:,1).^14 ...
zeros(size(X,1),1) ...
X(:,2) ...
2.*X(:,1).*X(:,2) ...
3.*X(:,1).^2.*X(:,2) ...
4.*X(:,1).^3.*X(:,2) ...
5.*X(:,1).^4.*X(:,2) ...
6.*X(:,1).^5.*X(:,2) ...
7.*X(:,1).^6.*X(:,2) ...
8.*X(:,1).^7.*X(:,2) ...
9.*X(:,1).^8.*X(:,2) ...
10.*X(:,1).^9.*X(:,2) ...
11.*X(:,1).^10.*X(:,2) ...
12.*X(:,1).^11.*X(:,2) ...
13.*X(:,1).^12.*X(:,2) ...
14.*X(:,1).^13.*X(:,2) ...
zeros(size(X,1),1) ...
X(:,2).^2 ...
2.*X(:,1).*X(:,2).^2 ...
3.*X(:,1).^2.*X(:,2).^2 ...
4.*X(:,1).^3.*X(:,2).^2 ...
5.*X(:,1).^4.*X(:,2).^2 ...
6.*X(:,1).^5.*X(:,2).^2 ...
7.*X(:,1).^6.*X(:,2).^2 ...
8.*X(:,1).^7.*X(:,2).^2 ...
9.*X(:,1).^8.*X(:,2).^2 ...
10.*X(:,1).^9.*X(:,2).^2 ...
11.*X(:,1).^10.*X(:,2).^2 ...
12.*X(:,1).^11.*X(:,2).^2 ...
13.*X(:,1).^12.*X(:,2).^2 ...
zeros(size(X,1),1) ...
X(:,2).^3 ...
2.*X(:,1).*X(:,2).^3 ...
3.*X(:,1).^2.*X(:,2).^3 ...
4.*X(:,1).^3.*X(:,2).^3 ...
5.*X(:,1).^4.*X(:,2).^3 ...
6.*X(:,1).^5.*X(:,2).^3 ...
7.*X(:,1).^6.*X(:,2).^3 ...
8.*X(:,1).^7.*X(:,2).^3 ...
9.*X(:,1).^8.*X(:,2).^3 ...
10.*X(:,1).^9.*X(:,2).^3 ...
11.*X(:,1).^10.*X(:,2).^3 ...
12.*X(:,1).^11.*X(:,2).^3 ...
zeros(size(X,1),1) ...
X(:,2).^4 ...
2.*X(:,1).*X(:,2).^4 ...
3.*X(:,1).^2.*X(:,2).^4 ...
4.*X(:,1).^3.*X(:,2).^4 ...
5.*X(:,1).^4.*X(:,2).^4 ...
6.*X(:,1).^5.*X(:,2).^4 ...
7.*X(:,1).^6.*X(:,2).^4 ...
8.*X(:,1).^7.*X(:,2).^4 ...
9.*X(:,1).^8.*X(:,2).^4 ...
10.*X(:,1).^9.*X(:,2).^4 ...
11.*X(:,1).^10.*X(:,2).^4 ...
zeros(size(X,1),1) ...
X(:,2).^5 ...
2.*X(:,1).*X(:,2).^5 ...
3.*X(:,1).^2.*X(:,2).^5 ...
4.*X(:,1).^3.*X(:,2).^5 ...
5.*X(:,1).^4.*X(:,2).^5 ...
6.*X(:,1).^5.*X(:,2).^5 ...
7.*X(:,1).^6.*X(:,2).^5 ...
8.*X(:,1).^7.*X(:,2).^5 ...
9.*X(:,1).^8.*X(:,2).^5 ...
10.*X(:,1).^9.*X(:,2).^5 ...
zeros(size(X,1),1) ...
X(:,2).^6 ...
2.*X(:,1).*X(:,2).^6 ...
3.*X(:,1).^2.*X(:,2).^6 ...
4.*X(:,1).^3.*X(:,2).^6 ...
5.*X(:,1).^4.*X(:,2).^6 ...
6.*X(:,1).^5.*X(:,2).^6 ...
7.*X(:,1).^6.*X(:,2).^6 ...
8.*X(:,1).^7.*X(:,2).^6 ...
9.*X(:,1).^8.*X(:,2).^6 ...
zeros(size(X,1),1) ...
X(:,2).^7 ...
2.*X(:,1).*X(:,2).^7 ...
3.*X(:,1).^2.*X(:,2).^7 ...
4.*X(:,1).^3.*X(:,2).^7 ...
5.*X(:,1).^4.*X(:,2).^7 ...
6.*X(:,1).^5.*X(:,2).^7 ...
7.*X(:,1).^6.*X(:,2).^7 ...
8.*X(:,1).^7.*X(:,2).^7 ...
zeros(size(X,1),1) ...
X(:,2).^8 ...
2.*X(:,1).*X(:,2).^8 ...
3.*X(:,1).^2.*X(:,2).^8 ...
4.*X(:,1).^3.*X(:,2).^8 ...
5.*X(:,1).^4.*X(:,2).^8 ...
6.*X(:,1).^5.*X(:,2).^8 ...
7.*X(:,1).^6.*X(:,2).^8 ...
zeros(size(X,1),1) ...
X(:,2).^9 ...
2.*X(:,1).*X(:,2).^9 ...
3.*X(:,1).^2.*X(:,2).^9 ...
4.*X(:,1).^3.*X(:,2).^9 ...
5.*X(:,1).^4.*X(:,2).^9 ...
6.*X(:,1).^5.*X(:,2).^9 ...
zeros(size(X,1),1) ...
X(:,2).^10 ...
2.*X(:,1).*X(:,2).^10 ...
3.*X(:,1).^2.*X(:,2).^10 ...
4.*X(:,1).^3.*X(:,2).^10 ...
5.*X(:,1).^4.*X(:,2).^10 ...
zeros(size(X,1),1) ...
X(:,2).^11 ...
2.*X(:,1).*X(:,2).^11 ...
3.*X(:,1).^2.*X(:,2).^11 ...
4.*X(:,1).^3.*X(:,2).^11 ...
zeros(size(X,1),1) ...
X(:,2).^12 ...
2.*X(:,1).*X(:,2).^12 ...
3.*X(:,1).^2.*X(:,2).^12 ...
zeros(size(X,1),1) ...
X(:,2).^13 ...
2.*X(:,1).*X(:,2).^13 ...
zeros(size(X,1),1) ...
X(:,2).^14 ...
zeros(size(X,1),1) ...
];

MatDX{2}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
X(:,1) ...
X(:,1).^2 ...
X(:,1).^3 ...
X(:,1).^4 ...
X(:,1).^5 ...
X(:,1).^6 ...
X(:,1).^7 ...
X(:,1).^8 ...
X(:,1).^9 ...
X(:,1).^10 ...
X(:,1).^11 ...
X(:,1).^12 ...
X(:,1).^13 ...
X(:,1).^14 ...
2.*X(:,2) ...
2.*X(:,1).*X(:,2) ...
2.*X(:,1).^2.*X(:,2) ...
2.*X(:,1).^3.*X(:,2) ...
2.*X(:,1).^4.*X(:,2) ...
2.*X(:,1).^5.*X(:,2) ...
2.*X(:,1).^6.*X(:,2) ...
2.*X(:,1).^7.*X(:,2) ...
2.*X(:,1).^8.*X(:,2) ...
2.*X(:,1).^9.*X(:,2) ...
2.*X(:,1).^10.*X(:,2) ...
2.*X(:,1).^11.*X(:,2) ...
2.*X(:,1).^12.*X(:,2) ...
2.*X(:,1).^13.*X(:,2) ...
3.*X(:,2).^2 ...
3.*X(:,1).*X(:,2).^2 ...
3.*X(:,1).^2.*X(:,2).^2 ...
3.*X(:,1).^3.*X(:,2).^2 ...
3.*X(:,1).^4.*X(:,2).^2 ...
3.*X(:,1).^5.*X(:,2).^2 ...
3.*X(:,1).^6.*X(:,2).^2 ...
3.*X(:,1).^7.*X(:,2).^2 ...
3.*X(:,1).^8.*X(:,2).^2 ...
3.*X(:,1).^9.*X(:,2).^2 ...
3.*X(:,1).^10.*X(:,2).^2 ...
3.*X(:,1).^11.*X(:,2).^2 ...
3.*X(:,1).^12.*X(:,2).^2 ...
4.*X(:,2).^3 ...
4.*X(:,1).*X(:,2).^3 ...
4.*X(:,1).^2.*X(:,2).^3 ...
4.*X(:,1).^3.*X(:,2).^3 ...
4.*X(:,1).^4.*X(:,2).^3 ...
4.*X(:,1).^5.*X(:,2).^3 ...
4.*X(:,1).^6.*X(:,2).^3 ...
4.*X(:,1).^7.*X(:,2).^3 ...
4.*X(:,1).^8.*X(:,2).^3 ...
4.*X(:,1).^9.*X(:,2).^3 ...
4.*X(:,1).^10.*X(:,2).^3 ...
4.*X(:,1).^11.*X(:,2).^3 ...
5.*X(:,2).^4 ...
5.*X(:,1).*X(:,2).^4 ...
5.*X(:,1).^2.*X(:,2).^4 ...
5.*X(:,1).^3.*X(:,2).^4 ...
5.*X(:,1).^4.*X(:,2).^4 ...
5.*X(:,1).^5.*X(:,2).^4 ...
5.*X(:,1).^6.*X(:,2).^4 ...
5.*X(:,1).^7.*X(:,2).^4 ...
5.*X(:,1).^8.*X(:,2).^4 ...
5.*X(:,1).^9.*X(:,2).^4 ...
5.*X(:,1).^10.*X(:,2).^4 ...
6.*X(:,2).^5 ...
6.*X(:,1).*X(:,2).^5 ...
6.*X(:,1).^2.*X(:,2).^5 ...
6.*X(:,1).^3.*X(:,2).^5 ...
6.*X(:,1).^4.*X(:,2).^5 ...
6.*X(:,1).^5.*X(:,2).^5 ...
6.*X(:,1).^6.*X(:,2).^5 ...
6.*X(:,1).^7.*X(:,2).^5 ...
6.*X(:,1).^8.*X(:,2).^5 ...
6.*X(:,1).^9.*X(:,2).^5 ...
7.*X(:,2).^6 ...
7.*X(:,1).*X(:,2).^6 ...
7.*X(:,1).^2.*X(:,2).^6 ...
7.*X(:,1).^3.*X(:,2).^6 ...
7.*X(:,1).^4.*X(:,2).^6 ...
7.*X(:,1).^5.*X(:,2).^6 ...
7.*X(:,1).^6.*X(:,2).^6 ...
7.*X(:,1).^7.*X(:,2).^6 ...
7.*X(:,1).^8.*X(:,2).^6 ...
8.*X(:,2).^7 ...
8.*X(:,1).*X(:,2).^7 ...
8.*X(:,1).^2.*X(:,2).^7 ...
8.*X(:,1).^3.*X(:,2).^7 ...
8.*X(:,1).^4.*X(:,2).^7 ...
8.*X(:,1).^5.*X(:,2).^7 ...
8.*X(:,1).^6.*X(:,2).^7 ...
8.*X(:,1).^7.*X(:,2).^7 ...
9.*X(:,2).^8 ...
9.*X(:,1).*X(:,2).^8 ...
9.*X(:,1).^2.*X(:,2).^8 ...
9.*X(:,1).^3.*X(:,2).^8 ...
9.*X(:,1).^4.*X(:,2).^8 ...
9.*X(:,1).^5.*X(:,2).^8 ...
9.*X(:,1).^6.*X(:,2).^8 ...
10.*X(:,2).^9 ...
10.*X(:,1).*X(:,2).^9 ...
10.*X(:,1).^2.*X(:,2).^9 ...
10.*X(:,1).^3.*X(:,2).^9 ...
10.*X(:,1).^4.*X(:,2).^9 ...
10.*X(:,1).^5.*X(:,2).^9 ...
11.*X(:,2).^10 ...
11.*X(:,1).*X(:,2).^10 ...
11.*X(:,1).^2.*X(:,2).^10 ...
11.*X(:,1).^3.*X(:,2).^10 ...
11.*X(:,1).^4.*X(:,2).^10 ...
12.*X(:,2).^11 ...
12.*X(:,1).*X(:,2).^11 ...
12.*X(:,1).^2.*X(:,2).^11 ...
12.*X(:,1).^3.*X(:,2).^11 ...
13.*X(:,2).^12 ...
13.*X(:,1).*X(:,2).^12 ...
13.*X(:,1).^2.*X(:,2).^12 ...
14.*X(:,2).^13 ...
14.*X(:,1).*X(:,2).^13 ...
15.*X(:,2).^14
];

CoefDX=[
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 0 1 2 3 4 5 6 7 8 9 10 11 12 13 0 1 2 3 4 5 6 7 8 9 10 11 12 0 1 2 3 4 5 6 7 8 9 10 11 0 1 2 3 4 5 6 7 8 9 10 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 0 1 2 3 4 5 0 1 2 3 4 0 1 2 3 0 1 2 0 1 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 9 9 9 9 9 9 9 10 10 10 10 10 10 11 11 11 11 11 12 12 12 12 13 13 13 14 14 15 
];
end

if dersecond
MatDDX=cell(size(X,2),size(X,2));

MatDDX{1}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*ones(size(X,1),1) ...
6.*X(:,1) ...
12.*X(:,1).^2 ...
20.*X(:,1).^3 ...
30.*X(:,1).^4 ...
42.*X(:,1).^5 ...
56.*X(:,1).^6 ...
72.*X(:,1).^7 ...
90.*X(:,1).^8 ...
110.*X(:,1).^9 ...
132.*X(:,1).^10 ...
156.*X(:,1).^11 ...
182.*X(:,1).^12 ...
210.*X(:,1).^13 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2) ...
6.*X(:,1).*X(:,2) ...
12.*X(:,1).^2.*X(:,2) ...
20.*X(:,1).^3.*X(:,2) ...
30.*X(:,1).^4.*X(:,2) ...
42.*X(:,1).^5.*X(:,2) ...
56.*X(:,1).^6.*X(:,2) ...
72.*X(:,1).^7.*X(:,2) ...
90.*X(:,1).^8.*X(:,2) ...
110.*X(:,1).^9.*X(:,2) ...
132.*X(:,1).^10.*X(:,2) ...
156.*X(:,1).^11.*X(:,2) ...
182.*X(:,1).^12.*X(:,2) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^2 ...
6.*X(:,1).*X(:,2).^2 ...
12.*X(:,1).^2.*X(:,2).^2 ...
20.*X(:,1).^3.*X(:,2).^2 ...
30.*X(:,1).^4.*X(:,2).^2 ...
42.*X(:,1).^5.*X(:,2).^2 ...
56.*X(:,1).^6.*X(:,2).^2 ...
72.*X(:,1).^7.*X(:,2).^2 ...
90.*X(:,1).^8.*X(:,2).^2 ...
110.*X(:,1).^9.*X(:,2).^2 ...
132.*X(:,1).^10.*X(:,2).^2 ...
156.*X(:,1).^11.*X(:,2).^2 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^3 ...
6.*X(:,1).*X(:,2).^3 ...
12.*X(:,1).^2.*X(:,2).^3 ...
20.*X(:,1).^3.*X(:,2).^3 ...
30.*X(:,1).^4.*X(:,2).^3 ...
42.*X(:,1).^5.*X(:,2).^3 ...
56.*X(:,1).^6.*X(:,2).^3 ...
72.*X(:,1).^7.*X(:,2).^3 ...
90.*X(:,1).^8.*X(:,2).^3 ...
110.*X(:,1).^9.*X(:,2).^3 ...
132.*X(:,1).^10.*X(:,2).^3 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^4 ...
6.*X(:,1).*X(:,2).^4 ...
12.*X(:,1).^2.*X(:,2).^4 ...
20.*X(:,1).^3.*X(:,2).^4 ...
30.*X(:,1).^4.*X(:,2).^4 ...
42.*X(:,1).^5.*X(:,2).^4 ...
56.*X(:,1).^6.*X(:,2).^4 ...
72.*X(:,1).^7.*X(:,2).^4 ...
90.*X(:,1).^8.*X(:,2).^4 ...
110.*X(:,1).^9.*X(:,2).^4 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^5 ...
6.*X(:,1).*X(:,2).^5 ...
12.*X(:,1).^2.*X(:,2).^5 ...
20.*X(:,1).^3.*X(:,2).^5 ...
30.*X(:,1).^4.*X(:,2).^5 ...
42.*X(:,1).^5.*X(:,2).^5 ...
56.*X(:,1).^6.*X(:,2).^5 ...
72.*X(:,1).^7.*X(:,2).^5 ...
90.*X(:,1).^8.*X(:,2).^5 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^6 ...
6.*X(:,1).*X(:,2).^6 ...
12.*X(:,1).^2.*X(:,2).^6 ...
20.*X(:,1).^3.*X(:,2).^6 ...
30.*X(:,1).^4.*X(:,2).^6 ...
42.*X(:,1).^5.*X(:,2).^6 ...
56.*X(:,1).^6.*X(:,2).^6 ...
72.*X(:,1).^7.*X(:,2).^6 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^7 ...
6.*X(:,1).*X(:,2).^7 ...
12.*X(:,1).^2.*X(:,2).^7 ...
20.*X(:,1).^3.*X(:,2).^7 ...
30.*X(:,1).^4.*X(:,2).^7 ...
42.*X(:,1).^5.*X(:,2).^7 ...
56.*X(:,1).^6.*X(:,2).^7 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^8 ...
6.*X(:,1).*X(:,2).^8 ...
12.*X(:,1).^2.*X(:,2).^8 ...
20.*X(:,1).^3.*X(:,2).^8 ...
30.*X(:,1).^4.*X(:,2).^8 ...
42.*X(:,1).^5.*X(:,2).^8 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^9 ...
6.*X(:,1).*X(:,2).^9 ...
12.*X(:,1).^2.*X(:,2).^9 ...
20.*X(:,1).^3.*X(:,2).^9 ...
30.*X(:,1).^4.*X(:,2).^9 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^10 ...
6.*X(:,1).*X(:,2).^10 ...
12.*X(:,1).^2.*X(:,2).^10 ...
20.*X(:,1).^3.*X(:,2).^10 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^11 ...
6.*X(:,1).*X(:,2).^11 ...
12.*X(:,1).^2.*X(:,2).^11 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^12 ...
6.*X(:,1).*X(:,2).^12 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*X(:,2).^13 ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
];

MatDDX{2}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3 ...
5.*X(:,1).^4 ...
6.*X(:,1).^5 ...
7.*X(:,1).^6 ...
8.*X(:,1).^7 ...
9.*X(:,1).^8 ...
10.*X(:,1).^9 ...
11.*X(:,1).^10 ...
12.*X(:,1).^11 ...
13.*X(:,1).^12 ...
14.*X(:,1).^13 ...
zeros(size(X,1),1) ...
2.*X(:,2) ...
4.*X(:,1).*X(:,2) ...
6.*X(:,1).^2.*X(:,2) ...
8.*X(:,1).^3.*X(:,2) ...
10.*X(:,1).^4.*X(:,2) ...
12.*X(:,1).^5.*X(:,2) ...
14.*X(:,1).^6.*X(:,2) ...
16.*X(:,1).^7.*X(:,2) ...
18.*X(:,1).^8.*X(:,2) ...
20.*X(:,1).^9.*X(:,2) ...
22.*X(:,1).^10.*X(:,2) ...
24.*X(:,1).^11.*X(:,2) ...
26.*X(:,1).^12.*X(:,2) ...
zeros(size(X,1),1) ...
3.*X(:,2).^2 ...
6.*X(:,1).*X(:,2).^2 ...
9.*X(:,1).^2.*X(:,2).^2 ...
12.*X(:,1).^3.*X(:,2).^2 ...
15.*X(:,1).^4.*X(:,2).^2 ...
18.*X(:,1).^5.*X(:,2).^2 ...
21.*X(:,1).^6.*X(:,2).^2 ...
24.*X(:,1).^7.*X(:,2).^2 ...
27.*X(:,1).^8.*X(:,2).^2 ...
30.*X(:,1).^9.*X(:,2).^2 ...
33.*X(:,1).^10.*X(:,2).^2 ...
36.*X(:,1).^11.*X(:,2).^2 ...
zeros(size(X,1),1) ...
4.*X(:,2).^3 ...
8.*X(:,1).*X(:,2).^3 ...
12.*X(:,1).^2.*X(:,2).^3 ...
16.*X(:,1).^3.*X(:,2).^3 ...
20.*X(:,1).^4.*X(:,2).^3 ...
24.*X(:,1).^5.*X(:,2).^3 ...
28.*X(:,1).^6.*X(:,2).^3 ...
32.*X(:,1).^7.*X(:,2).^3 ...
36.*X(:,1).^8.*X(:,2).^3 ...
40.*X(:,1).^9.*X(:,2).^3 ...
44.*X(:,1).^10.*X(:,2).^3 ...
zeros(size(X,1),1) ...
5.*X(:,2).^4 ...
10.*X(:,1).*X(:,2).^4 ...
15.*X(:,1).^2.*X(:,2).^4 ...
20.*X(:,1).^3.*X(:,2).^4 ...
25.*X(:,1).^4.*X(:,2).^4 ...
30.*X(:,1).^5.*X(:,2).^4 ...
35.*X(:,1).^6.*X(:,2).^4 ...
40.*X(:,1).^7.*X(:,2).^4 ...
45.*X(:,1).^8.*X(:,2).^4 ...
50.*X(:,1).^9.*X(:,2).^4 ...
zeros(size(X,1),1) ...
6.*X(:,2).^5 ...
12.*X(:,1).*X(:,2).^5 ...
18.*X(:,1).^2.*X(:,2).^5 ...
24.*X(:,1).^3.*X(:,2).^5 ...
30.*X(:,1).^4.*X(:,2).^5 ...
36.*X(:,1).^5.*X(:,2).^5 ...
42.*X(:,1).^6.*X(:,2).^5 ...
48.*X(:,1).^7.*X(:,2).^5 ...
54.*X(:,1).^8.*X(:,2).^5 ...
zeros(size(X,1),1) ...
7.*X(:,2).^6 ...
14.*X(:,1).*X(:,2).^6 ...
21.*X(:,1).^2.*X(:,2).^6 ...
28.*X(:,1).^3.*X(:,2).^6 ...
35.*X(:,1).^4.*X(:,2).^6 ...
42.*X(:,1).^5.*X(:,2).^6 ...
49.*X(:,1).^6.*X(:,2).^6 ...
56.*X(:,1).^7.*X(:,2).^6 ...
zeros(size(X,1),1) ...
8.*X(:,2).^7 ...
16.*X(:,1).*X(:,2).^7 ...
24.*X(:,1).^2.*X(:,2).^7 ...
32.*X(:,1).^3.*X(:,2).^7 ...
40.*X(:,1).^4.*X(:,2).^7 ...
48.*X(:,1).^5.*X(:,2).^7 ...
56.*X(:,1).^6.*X(:,2).^7 ...
zeros(size(X,1),1) ...
9.*X(:,2).^8 ...
18.*X(:,1).*X(:,2).^8 ...
27.*X(:,1).^2.*X(:,2).^8 ...
36.*X(:,1).^3.*X(:,2).^8 ...
45.*X(:,1).^4.*X(:,2).^8 ...
54.*X(:,1).^5.*X(:,2).^8 ...
zeros(size(X,1),1) ...
10.*X(:,2).^9 ...
20.*X(:,1).*X(:,2).^9 ...
30.*X(:,1).^2.*X(:,2).^9 ...
40.*X(:,1).^3.*X(:,2).^9 ...
50.*X(:,1).^4.*X(:,2).^9 ...
zeros(size(X,1),1) ...
11.*X(:,2).^10 ...
22.*X(:,1).*X(:,2).^10 ...
33.*X(:,1).^2.*X(:,2).^10 ...
44.*X(:,1).^3.*X(:,2).^10 ...
zeros(size(X,1),1) ...
12.*X(:,2).^11 ...
24.*X(:,1).*X(:,2).^11 ...
36.*X(:,1).^2.*X(:,2).^11 ...
zeros(size(X,1),1) ...
13.*X(:,2).^12 ...
26.*X(:,1).*X(:,2).^12 ...
zeros(size(X,1),1) ...
14.*X(:,2).^13 ...
zeros(size(X,1),1) ...
];

MatDDX{3}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
ones(size(X,1),1) ...
2.*X(:,1) ...
3.*X(:,1).^2 ...
4.*X(:,1).^3 ...
5.*X(:,1).^4 ...
6.*X(:,1).^5 ...
7.*X(:,1).^6 ...
8.*X(:,1).^7 ...
9.*X(:,1).^8 ...
10.*X(:,1).^9 ...
11.*X(:,1).^10 ...
12.*X(:,1).^11 ...
13.*X(:,1).^12 ...
14.*X(:,1).^13 ...
zeros(size(X,1),1) ...
2.*X(:,2) ...
4.*X(:,1).*X(:,2) ...
6.*X(:,1).^2.*X(:,2) ...
8.*X(:,1).^3.*X(:,2) ...
10.*X(:,1).^4.*X(:,2) ...
12.*X(:,1).^5.*X(:,2) ...
14.*X(:,1).^6.*X(:,2) ...
16.*X(:,1).^7.*X(:,2) ...
18.*X(:,1).^8.*X(:,2) ...
20.*X(:,1).^9.*X(:,2) ...
22.*X(:,1).^10.*X(:,2) ...
24.*X(:,1).^11.*X(:,2) ...
26.*X(:,1).^12.*X(:,2) ...
zeros(size(X,1),1) ...
3.*X(:,2).^2 ...
6.*X(:,1).*X(:,2).^2 ...
9.*X(:,1).^2.*X(:,2).^2 ...
12.*X(:,1).^3.*X(:,2).^2 ...
15.*X(:,1).^4.*X(:,2).^2 ...
18.*X(:,1).^5.*X(:,2).^2 ...
21.*X(:,1).^6.*X(:,2).^2 ...
24.*X(:,1).^7.*X(:,2).^2 ...
27.*X(:,1).^8.*X(:,2).^2 ...
30.*X(:,1).^9.*X(:,2).^2 ...
33.*X(:,1).^10.*X(:,2).^2 ...
36.*X(:,1).^11.*X(:,2).^2 ...
zeros(size(X,1),1) ...
4.*X(:,2).^3 ...
8.*X(:,1).*X(:,2).^3 ...
12.*X(:,1).^2.*X(:,2).^3 ...
16.*X(:,1).^3.*X(:,2).^3 ...
20.*X(:,1).^4.*X(:,2).^3 ...
24.*X(:,1).^5.*X(:,2).^3 ...
28.*X(:,1).^6.*X(:,2).^3 ...
32.*X(:,1).^7.*X(:,2).^3 ...
36.*X(:,1).^8.*X(:,2).^3 ...
40.*X(:,1).^9.*X(:,2).^3 ...
44.*X(:,1).^10.*X(:,2).^3 ...
zeros(size(X,1),1) ...
5.*X(:,2).^4 ...
10.*X(:,1).*X(:,2).^4 ...
15.*X(:,1).^2.*X(:,2).^4 ...
20.*X(:,1).^3.*X(:,2).^4 ...
25.*X(:,1).^4.*X(:,2).^4 ...
30.*X(:,1).^5.*X(:,2).^4 ...
35.*X(:,1).^6.*X(:,2).^4 ...
40.*X(:,1).^7.*X(:,2).^4 ...
45.*X(:,1).^8.*X(:,2).^4 ...
50.*X(:,1).^9.*X(:,2).^4 ...
zeros(size(X,1),1) ...
6.*X(:,2).^5 ...
12.*X(:,1).*X(:,2).^5 ...
18.*X(:,1).^2.*X(:,2).^5 ...
24.*X(:,1).^3.*X(:,2).^5 ...
30.*X(:,1).^4.*X(:,2).^5 ...
36.*X(:,1).^5.*X(:,2).^5 ...
42.*X(:,1).^6.*X(:,2).^5 ...
48.*X(:,1).^7.*X(:,2).^5 ...
54.*X(:,1).^8.*X(:,2).^5 ...
zeros(size(X,1),1) ...
7.*X(:,2).^6 ...
14.*X(:,1).*X(:,2).^6 ...
21.*X(:,1).^2.*X(:,2).^6 ...
28.*X(:,1).^3.*X(:,2).^6 ...
35.*X(:,1).^4.*X(:,2).^6 ...
42.*X(:,1).^5.*X(:,2).^6 ...
49.*X(:,1).^6.*X(:,2).^6 ...
56.*X(:,1).^7.*X(:,2).^6 ...
zeros(size(X,1),1) ...
8.*X(:,2).^7 ...
16.*X(:,1).*X(:,2).^7 ...
24.*X(:,1).^2.*X(:,2).^7 ...
32.*X(:,1).^3.*X(:,2).^7 ...
40.*X(:,1).^4.*X(:,2).^7 ...
48.*X(:,1).^5.*X(:,2).^7 ...
56.*X(:,1).^6.*X(:,2).^7 ...
zeros(size(X,1),1) ...
9.*X(:,2).^8 ...
18.*X(:,1).*X(:,2).^8 ...
27.*X(:,1).^2.*X(:,2).^8 ...
36.*X(:,1).^3.*X(:,2).^8 ...
45.*X(:,1).^4.*X(:,2).^8 ...
54.*X(:,1).^5.*X(:,2).^8 ...
zeros(size(X,1),1) ...
10.*X(:,2).^9 ...
20.*X(:,1).*X(:,2).^9 ...
30.*X(:,1).^2.*X(:,2).^9 ...
40.*X(:,1).^3.*X(:,2).^9 ...
50.*X(:,1).^4.*X(:,2).^9 ...
zeros(size(X,1),1) ...
11.*X(:,2).^10 ...
22.*X(:,1).*X(:,2).^10 ...
33.*X(:,1).^2.*X(:,2).^10 ...
44.*X(:,1).^3.*X(:,2).^10 ...
zeros(size(X,1),1) ...
12.*X(:,2).^11 ...
24.*X(:,1).*X(:,2).^11 ...
36.*X(:,1).^2.*X(:,2).^11 ...
zeros(size(X,1),1) ...
13.*X(:,2).^12 ...
26.*X(:,1).*X(:,2).^12 ...
zeros(size(X,1),1) ...
14.*X(:,2).^13 ...
zeros(size(X,1),1) ...
];

MatDDX{4}=[
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
zeros(size(X,1),1) ...
2.*ones(size(X,1),1) ...
2.*X(:,1) ...
2.*X(:,1).^2 ...
2.*X(:,1).^3 ...
2.*X(:,1).^4 ...
2.*X(:,1).^5 ...
2.*X(:,1).^6 ...
2.*X(:,1).^7 ...
2.*X(:,1).^8 ...
2.*X(:,1).^9 ...
2.*X(:,1).^10 ...
2.*X(:,1).^11 ...
2.*X(:,1).^12 ...
2.*X(:,1).^13 ...
6.*X(:,2) ...
6.*X(:,1).*X(:,2) ...
6.*X(:,1).^2.*X(:,2) ...
6.*X(:,1).^3.*X(:,2) ...
6.*X(:,1).^4.*X(:,2) ...
6.*X(:,1).^5.*X(:,2) ...
6.*X(:,1).^6.*X(:,2) ...
6.*X(:,1).^7.*X(:,2) ...
6.*X(:,1).^8.*X(:,2) ...
6.*X(:,1).^9.*X(:,2) ...
6.*X(:,1).^10.*X(:,2) ...
6.*X(:,1).^11.*X(:,2) ...
6.*X(:,1).^12.*X(:,2) ...
12.*X(:,2).^2 ...
12.*X(:,1).*X(:,2).^2 ...
12.*X(:,1).^2.*X(:,2).^2 ...
12.*X(:,1).^3.*X(:,2).^2 ...
12.*X(:,1).^4.*X(:,2).^2 ...
12.*X(:,1).^5.*X(:,2).^2 ...
12.*X(:,1).^6.*X(:,2).^2 ...
12.*X(:,1).^7.*X(:,2).^2 ...
12.*X(:,1).^8.*X(:,2).^2 ...
12.*X(:,1).^9.*X(:,2).^2 ...
12.*X(:,1).^10.*X(:,2).^2 ...
12.*X(:,1).^11.*X(:,2).^2 ...
20.*X(:,2).^3 ...
20.*X(:,1).*X(:,2).^3 ...
20.*X(:,1).^2.*X(:,2).^3 ...
20.*X(:,1).^3.*X(:,2).^3 ...
20.*X(:,1).^4.*X(:,2).^3 ...
20.*X(:,1).^5.*X(:,2).^3 ...
20.*X(:,1).^6.*X(:,2).^3 ...
20.*X(:,1).^7.*X(:,2).^3 ...
20.*X(:,1).^8.*X(:,2).^3 ...
20.*X(:,1).^9.*X(:,2).^3 ...
20.*X(:,1).^10.*X(:,2).^3 ...
30.*X(:,2).^4 ...
30.*X(:,1).*X(:,2).^4 ...
30.*X(:,1).^2.*X(:,2).^4 ...
30.*X(:,1).^3.*X(:,2).^4 ...
30.*X(:,1).^4.*X(:,2).^4 ...
30.*X(:,1).^5.*X(:,2).^4 ...
30.*X(:,1).^6.*X(:,2).^4 ...
30.*X(:,1).^7.*X(:,2).^4 ...
30.*X(:,1).^8.*X(:,2).^4 ...
30.*X(:,1).^9.*X(:,2).^4 ...
42.*X(:,2).^5 ...
42.*X(:,1).*X(:,2).^5 ...
42.*X(:,1).^2.*X(:,2).^5 ...
42.*X(:,1).^3.*X(:,2).^5 ...
42.*X(:,1).^4.*X(:,2).^5 ...
42.*X(:,1).^5.*X(:,2).^5 ...
42.*X(:,1).^6.*X(:,2).^5 ...
42.*X(:,1).^7.*X(:,2).^5 ...
42.*X(:,1).^8.*X(:,2).^5 ...
56.*X(:,2).^6 ...
56.*X(:,1).*X(:,2).^6 ...
56.*X(:,1).^2.*X(:,2).^6 ...
56.*X(:,1).^3.*X(:,2).^6 ...
56.*X(:,1).^4.*X(:,2).^6 ...
56.*X(:,1).^5.*X(:,2).^6 ...
56.*X(:,1).^6.*X(:,2).^6 ...
56.*X(:,1).^7.*X(:,2).^6 ...
72.*X(:,2).^7 ...
72.*X(:,1).*X(:,2).^7 ...
72.*X(:,1).^2.*X(:,2).^7 ...
72.*X(:,1).^3.*X(:,2).^7 ...
72.*X(:,1).^4.*X(:,2).^7 ...
72.*X(:,1).^5.*X(:,2).^7 ...
72.*X(:,1).^6.*X(:,2).^7 ...
90.*X(:,2).^8 ...
90.*X(:,1).*X(:,2).^8 ...
90.*X(:,1).^2.*X(:,2).^8 ...
90.*X(:,1).^3.*X(:,2).^8 ...
90.*X(:,1).^4.*X(:,2).^8 ...
90.*X(:,1).^5.*X(:,2).^8 ...
110.*X(:,2).^9 ...
110.*X(:,1).*X(:,2).^9 ...
110.*X(:,1).^2.*X(:,2).^9 ...
110.*X(:,1).^3.*X(:,2).^9 ...
110.*X(:,1).^4.*X(:,2).^9 ...
132.*X(:,2).^10 ...
132.*X(:,1).*X(:,2).^10 ...
132.*X(:,1).^2.*X(:,2).^10 ...
132.*X(:,1).^3.*X(:,2).^10 ...
156.*X(:,2).^11 ...
156.*X(:,1).*X(:,2).^11 ...
156.*X(:,1).^2.*X(:,2).^11 ...
182.*X(:,2).^12 ...
182.*X(:,1).*X(:,2).^12 ...
210.*X(:,2).^13
];

CoefDDX=[
0 0 2 6 12 20 30 42 56 72 90 110 132 156 182 210 0 0 2 6 12 20 30 42 56 72 90 110 132 156 182 0 0 2 6 12 20 30 42 56 72 90 110 132 156 0 0 2 6 12 20 30 42 56 72 90 110 132 0 0 2 6 12 20 30 42 56 72 90 110 0 0 2 6 12 20 30 42 56 72 90 0 0 2 6 12 20 30 42 56 72 0 0 2 6 12 20 30 42 56 0 0 2 6 12 20 30 42 0 0 2 6 12 20 30 0 0 2 6 12 20 0 0 2 6 12 0 0 2 6 0 0 2 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 0 2 4 6 8 10 12 14 16 18 20 22 24 26 0 3 6 9 12 15 18 21 24 27 30 33 36 0 4 8 12 16 20 24 28 32 36 40 44 0 5 10 15 20 25 30 35 40 45 50 0 6 12 18 24 30 36 42 48 54 0 7 14 21 28 35 42 49 56 0 8 16 24 32 40 48 56 0 9 18 27 36 45 54 0 10 20 30 40 50 0 11 22 33 44 0 12 24 36 0 13 26 0 14 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 0 2 4 6 8 10 12 14 16 18 20 22 24 26 0 3 6 9 12 15 18 21 24 27 30 33 36 0 4 8 12 16 20 24 28 32 36 40 44 0 5 10 15 20 25 30 35 40 45 50 0 6 12 18 24 30 36 42 48 54 0 7 14 21 28 35 42 49 56 0 8 16 24 32 40 48 56 0 9 18 27 36 45 54 0 10 20 30 40 50 0 11 22 33 44 0 12 24 36 0 13 26 0 14 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 2 2 2 2 2 2 2 2 2 2 2 2 6 6 6 6 6 6 6 6 6 6 6 6 6 12 12 12 12 12 12 12 12 12 12 12 12 20 20 20 20 20 20 20 20 20 20 20 30 30 30 30 30 30 30 30 30 30 42 42 42 42 42 42 42 42 42 56 56 56 56 56 56 56 56 72 72 72 72 72 72 72 90 90 90 90 90 90 110 110 110 110 110 132 132 132 132 156 156 156 182 182 210 
];
end

end

