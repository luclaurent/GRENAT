function y = PrWc1(x)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Welded beam design problem, constraints
% Parameters
P = 6000; L = 14;
t_max = 13600;
M = P.*(L+x(:,2)./2); R = sqrt(0.25.*(x(:,2).^2+(x(:,1)+x(:,3)).^2));
J = 2./sqrt(2).*x(:,1).*x(:,2).*(x(:,2).^2./12+0.25.*(x(:,1)+x(:,3)).^2);
t1 = P./(sqrt(2).*x(:,1).*x(:,2)); t2 = M.*R./J;
t = sqrt(t1.^2+t1.*t2.*x(:,2)./R+t2.^2);
% Constraints
y = t-t_max;
% Variable lower bounds
%y(7) = -x(1)+0.125;
%y(8) = -x(2)+0.1;
%y(9) = -x(3)+0.1;
%y(10) = -x(4)+0.1;
% Variable upper bounds
%y(11) = x(1)-10;
%y(12) = x(2)-10;
%y(13) = x(3)-10;
%y(14) = x(4)-10;
