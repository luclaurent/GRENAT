

function [alpha_pm,lambda_pm,sv_i,SVRmu]=dsvrbuild(XXX,YYY,dYYY,sigma,e,ek,C,Ck,xi,taui,funKernel,dfunKernel,ddfunKernel)

ns=length(XXX);

PsiM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiM(i,j)=funKernel(XXX(i)-XXX(j),sigma);
    end
end
PsiDoM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiDoM(i,j)=-dfunKernel(XXX(i)-XXX(j),sigma);
    end
end
PsiDDoM=zeros(ns,ns);
for j=1:ns
    for i=1:ns
        PsiDDoM(i,j)=-ddfunKernel(XXX(i)-XXX(j),sigma);
    end
end


Psi=[PsiM -PsiM;-PsiM PsiM];
Psi=[PsiM -PsiM;-PsiM PsiM];
PsiDo=[PsiDoM -PsiDoM;-PsiDoM PsiDoM];
PsiDDo=[PsiDDoM -PsiDDoM;-PsiDDoM PsiDDoM];
PsiT=[Psi PsiDo;PsiDo' PsiDDo];

cond(PsiT)

c=[(e*ones(ns,1)-YYY);(e*ones(ns,1)+YYY);...
    (ek*ones(ns,1)-dYYY);(ek*ones(ns,1)+dYYY)];

lb=zeros(4*ns,1);
ub=[C/ns*ones(2*ns,1);Ck/ns*ones(2*ns,1)];

x0=zeros(4*ns,1);

Aeq=[ones(1,ns) -ones(1,ns) zeros(1,ns) zeros(1,ns)];
beq=0;

opts = optimoptions('quadprog','Diagnostics','off','Display','iter');

alphalambda=quadprog(PsiT,c,[],[],Aeq,beq,lb,ub,x0,opts);


alpha_pm=alphalambda(1:ns)-alphalambda(ns+1:2*ns);
lambda_pm=alphalambda(2*ns+1:3*ns)-alphalambda(3*ns+1:4*ns);

sv_i=find(abs(alpha_pm)>xi);
sv_di=find(abs(lambda_pm)>taui);

[sv_mid,sv_mid_i]=min(abs(abs(alpha_pm)-(C/(2*ns))));
[sv_midd,sv_midd_i]=min(abs(abs(lambda_pm)-(Ck/(2*ns))));
keyboard

SVRmu=YYY(sv_mid_i)-e*sign(alpha_pm(sv_mid_i))...
    -alpha_pm(sv_i)'*Psi(sv_i,sv_mid_i)...
    -lambda_pm(sv_i)'*PsiDo(sv_mid_i,sv_i)';

SVRmu
keyboard









