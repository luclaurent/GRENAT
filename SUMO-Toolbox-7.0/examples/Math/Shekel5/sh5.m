% shekel for m = 5
function f = sh5(x1, x2, x3, x4)

x = [x1 x2 x3 x4];

a = [4.0d0, 1.0d0, 8.0d0, 6.0d0, 3.0d0;
     4.0d0, 1.0d0, 8.0d0, 6.0d0, 7.0d0;
     4.0d0, 1.0d0, 8.0d0, 6.0d0, 3.0d0;
     4.0d0, 1.0d0, 8.0d0, 6.0d0, 7.0d0];
c = [0.1d0, 0.2d0, 0.2d0, 0.4d0, 0.4d0];
if size(x,1) == 1
 x = x';
end
for i=1:5
 b = (x - a(:,i)).^2;
 d(i) = sum(b);
end
f = -sum((c+d).^(-1));
