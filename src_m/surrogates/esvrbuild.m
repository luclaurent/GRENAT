

function [alpha_pm,sv_i,mu,e]=esvrbuild(XXX,YYY,sigma,nu,C,xi,funKernel)

ns=length(XXX);

PsiM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiM(i,j)=funKernel(XXX(i),XXX(j),sigma);
    end
end


Psi=[PsiM -PsiM;-PsiM PsiM];
c=[-YYY;YYY];

lb=zeros(2*ns,1);
ub=C/ns*ones(2*ns,1);

x0=zeros(2*ns,1);

Aeq=[ones(1,ns) -ones(1,ns)];
beq=0;

%pour nu-SVR
A=[ones(1,ns) ones(1,ns)];
b=C*nu;

opts = optimoptions('quadprog','Diagnostics','off','Display','iter');
alpha=quadprog(Psi,c,A,b,Aeq,beq,lb,ub,x0,opts);

alpha_pm=alpha(1:ns)-alpha(ns+1:2*ns);

sv_i=find(abs(alpha_pm)>xi);
[sv_mid_p,sv_mid_p_i]=min(abs(abs(alpha(1:ns))-(C/(2*ns))));
[sv_mid_m,sv_mid_m_i]=min(abs(abs(alpha(ns+1:2*ns))-(C/(2*ns))));

e=0.5*(YYY(sv_mid_p_i)-YYY(sv_mid_m_i)-alpha_pm(sv_i)'*...
    Psi(sv_i,sv_mid_p_i)+alpha_pm(sv_i)'*Psi(sv_i,sv_mid_m_i));
mu=YYY(sv_mid_p_i)-e*sign(alpha_pm(sv_mid_p_i))...
    -alpha_pm(sv_i)'*Psi(sv_i,sv_mid_p_i);












