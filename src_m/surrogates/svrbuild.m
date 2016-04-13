

function [alpha_pm,sv_i,SVRmu]=svrbuild(XXX,YYY,sigma,e,C,xi,funKernel)


ns=length(XXX);

PsiM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiM(i,j)=funKernel(XXX(i),XXX(j),sigma);
    end
end


Psi=[PsiM -PsiM;-PsiM PsiM];
cond(Psi)

c=[(e*ones(ns,1)-YYY);(e*ones(ns,1)+YYY)];

lb=zeros(2*ns,1);
ub=C/ns*ones(2*ns,1);

x0=zeros(2*ns,1);

Aeq=[ones(1,ns) -ones(1,ns)];
beq=0;

opts = optimoptions('quadprog','Diagnostics','off','Display','iter');

alpha=quadprog(Psi,c,[],[],Aeq,beq,lb,ub,x0,opts);


alpha_pm=alpha(1:ns)-alpha(ns+1:2*ns);

sv_i=find(abs(alpha_pm)>xi);

[sv_mid,sv_mid_i]=min(abs(abs(alpha_pm)-(C/(2*ns))));
SVRmu=YYY(sv_mid_i)-e*sign(alpha_pm(sv_mid_i))-alpha_pm(sv_i)'*Psi(sv_i,sv_mid_i);












