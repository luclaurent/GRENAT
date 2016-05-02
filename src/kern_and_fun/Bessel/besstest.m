% Test Bessel functions
% CBM, 5-19-90, 10-12-92, 4-10-94.
disp('In besstest');
i = 1i;
test = zeros(31,1);

% JNL's favorite z's.
z = [.5 1 2.1 3 20 [.5 1 2 3 7]*i .7+.6*i].';

v = [ 9.384698072408129e-01                         
      7.651976865579665e-01                         
      1.666069803319904e-01                         
     -2.600519549019334e-01                         
      1.670246643405832e-01                         
      1.063483370741324e+00                         
      1.266065877752008e+00                         
      2.279585302336068e+00                         
      4.880792585865025e+00                         
      1.685939085102897e+02                         
      9.568604185646874e-01-2.063507959777426e-01*i];
nu = 0;
w = besselj(nu,z);
test(1) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(2) = max(abs((v-w)./v));


v = [ 9.384698072408129e-01-4.445187335067066e-01*i
      7.651976865579665e-01+8.825696421567698e-02*i
      1.666069803319904e-01+5.182937375137607e-01*i
     -2.600519549019334e-01+3.768500100127905e-01*i
      1.670246643405832e-01+6.264059680938383e-02*i];
nu = 0;
w = besselj(nu,z(1:5))+i*bessely(nu,z(1:5));
test(3) = max(abs((v-w)./v));
w = besselh(nu,z(1:5));
test(4) = max(abs((v-w)./v));

v = [ 2.422684576748739e-01                         
      4.400505857449335e-01                         
      5.682921357570387e-01                         
      3.390589585259365e-01                         
      6.683312417584988e-02                   
                           +2.578943053908964e-01*i
                           +5.651591039924850e-01*i
                           +1.590636854637329e+00*i
                           +3.953370217402611e+00*i
                           +1.560390928699554e+02*i
      3.742085919913218e-01+2.577268380135428e-01*i];
nu = 1;
w = besselj(nu,z);
test(5) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(6) = max(abs((v-w)./v));

v = [ 2.422684576748739e-01-1.471472392670243e+00*i
      4.400505857449335e-01-7.812128213002888e-01*i
      5.682921357570387e-01-5.167861213042339e-02*i
      3.390589585259365e-01+3.246744247917998e-01*i
      6.683312417584988e-02-1.655116143625213e-01*i];
nu = 1;
w = besselj(nu,z(1:5))+i*bessely(nu,z(1:5));
test(7) = max(abs((v-w)./v));
w = besselh(nu,z(1:5));
test(8) = max(abs((v-w)./v));

v = [ 5.941853962232460e-15                         
      1.198006746303137e-11                         
      3.907360863748964e-08                         
      1.793989662347447e-06                         
      6.135630337595076e-02                         
                           -6.004071769010598e-15*i
                           -1.248978308492491e-11*i
                           -2.722202335975358e-08*i
                           -2.610365694084158e-06*i
                           -6.471863302002204e-02*i
      3.818827706321378e-13+4.975903573585851e-12*i];
nu = 11;
w = besselj(nu,z);
test(9) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(10) = max(abs((v-w)./v));

v = [ 5.941853962232460e-15-4.875154108838144e+12*i
      1.198006746303137e-11-2.425580080635051e+09*i
      3.907360863748964e-08-7.545893279942343e+05*i
      1.793989080482030e-06-1.677242135916440e+04*i
      6.135630337595114e-02-1.851336803929670e-01*i];
nu = 11;
w = besselj(nu,z(1:5))+i*bessely(nu,z(1:5));
test(11) = max(abs((v-w)./v));
w = besselh(nu,z(1:5));
test(12) = max(abs((v-w)./v));

v = [ 5.409737899345283e-01                         
      6.713967071418032e-01                         
      4.752767376437600e-01                         
      6.500818287737581e-02
      1.628807638550298e-01                         
      4.157738989603137e-01+4.157738989603136e-01*i
      6.630362720267226e-01+6.630362720267226e-01*i
      1.446907961804160e+00+1.446907961804160e+00*i
      3.263172568974507e+00+3.263172568974507e+00*i
      1.169249142760799e+02+1.169249142760798e+02*i
      7.355766388662828e-01+1.593229025505583e-01*i];
nu = 0.5;
w = besselj(nu,z);
test(13) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(14) = max(abs((v-w)./v));

v = [ 1.287635961816976e-01                         
      2.989106426572380e-01                         
      5.372149630489751e-01                         
      4.476018635473902e-01
     -2.144834387372124e-02                         
     -6.792500015258053e-02+1.176495513683933e-01*i
     -1.851927065749895e-01+3.207631769790768e-01*i
     -6.290912055151691e-01+1.089617930547027e+00*i
     -1.696280018967008e+00+2.938043176714759e+00*i
     -7.348335956084084e+01+1.272769122702286e+02*i
      1.938952775960584e-01+2.227266961808092e-01*i];
nu = 4/3;
w = besselj(nu,z);
test(15) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(16) = max(abs((v-w)./v));

v = [ 9.972516950322939e-13                         
      7.817556793810863e-10                         
      9.210352060478841e-07                         
      2.570647695197615e-05
      1.883403011605838e-01                         
     -8.519577957566307e-13+5.406688578803327e-13*i
     -6.918163550382292e-10+4.390400092639131e-10*i
     -5.920793943600938e-07+3.757450093391668e-07*i
     -3.313356350344531e-05+2.102719879569084e-05*i
     -2.847199569476569e-01+1.806887790749217e-01*i
      3.148680593468679e-10+1.837386711434257e-10*i];
nu = 9.64;
w = besselj(nu,z);
test(17) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(18) = max(abs((v-w)./v));


% LS's z's 
z = (10:10:50)'*(-1+i);

nu = 10.5;
v = [-1.099628771331206e+02-7.048670717290774e+01*i
      8.860796718260860e+06-1.838967703805381e+06*i
     -2.592642700116440e+11+2.490771262497038e+10*i
      6.076615045434029e+15+1.527094782186220e+15*i
     -1.100816565414841e+20-8.933922978498091e+19*i];
w = besselj(nu,z);
test(19) = max(abs((v-w)./v));
w = i^nu*besseli(nu,z/i);
test(20) = max(abs((v-w)./v));

% Examples used in HELP entries

w = besselj(3:9,(10:.2:20)');
if any(size(w) ~= [51 7]), error('Bessel size error.'), end
test(21) = abs(sum(sum(w)) - 2.956620684302697e+00);

w = bessely(3:9,(10:.2:20)');
if any(size(w) ~= [51 7]), error('Bessel size error.'), end
test(22) = abs(sum(sum(w)) - 3.299729060132027e+00);

w = besseli(3:9,[0:.2:9.8 10:.5:20],1);
if any(size(w) ~= [71 7]), error('Bessel size error.'), end
test(23) = abs(sum(sum(w)) - 1.078340600319415e+01);

w = besselk(3:9,[0:.2:9.8 10:.5:20],1);
if any(size(w) ~= [71 7]), error('Bessel size error.'), end
test(24) = abs(sum(sum(w(finite(w)))) - 2.496662543120248e+13)/1.e13;

[x,y] = meshgrid(-4:0.25:2,-1.5:0.25:1.5);
w = besselh(0,1,x+i*y);
if any(size(w) ~= [13 25]), error('Bessel size error'), end
test(25) = abs(sum(sum(w(finite(w)))) - ...
   (1.292782127614014e+02 - 1.956969558647155e+01i))/100;

% Some special values

test(26) = abs(besselj(0,100) - 1.998585030422312e-02);
test(27) = abs(besselj(1,100) - (-7.714535201411214e-02));
test(28) = abs(besselj(0,100)+i*bessely(0,100) -  ...
   (1.998585030422330e-02 - 7.724431336508336e-02*i));
test(30) = abs(besselj(1,100)+i*bessely(1,100) - ...
   (-7.714535201411236e-02 - 2.037231200275802e-02*i));
test(31) = abs(besselh(1,100) - ...
   (-7.714535201411236e-02 - 2.037231200275802e-02*i));

if besselj(0,0) ~= 1, error('besselj(0,0) should = 1.'), end
if besselj(1,0) ~= 0, error('besselj(1,0) should = 0.'), end
if besselj(100,0) ~= 0, error('besselj(100,0) should = 0.'), end
if isieee
   if ~isinf(bessely(0,0)), error('bessely(0,0) should = inf.'), end
   if ~isinf(bessely(1,0)), error('bessely(1,0) should = inf.'), end
   if ~isinf(bessely(100,0)), error('bessely(100,0) should = inf.'), end
end

maxerr = max(test)
k = find(test == maxerr);
if maxerr > 1.e6*eps
   error(['besstest maxerr too large. k = ' int2str(k)])
elseif maxerr > 1.e3*eps
   disp(['Warning: besstest maxerr is suspicious. k = ' int2str(k)])
else
   disp('besstest passed OK')
end
