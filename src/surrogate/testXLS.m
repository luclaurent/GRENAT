sampling=[10 20 30;50 60 70; 80 90 50;-1 2 3;4 5 6;10 50 60]/90;
%resp=[10;20;NaN];
%grad=[10 NaN 80;20 30 50;NaN NaN NaN];
resp=[10;20;30;5;-1;-5];
grad=[10 5 80;20 30 50;20 -10 5;10 50 -20;-4 5 6; 5 48 49];

ns=100;
sampling=randn(ns,3);
resp=randn(ns,1);
grad=randn(ns,3);
%
MM=MissData(sampling,resp,[]);
%kk=xLS(sampling,resp,grad,2,MM);
PP=initMeta;
PP.estimOn=true;
%PP.cv.full=true;
kk=RBF(sampling,resp,grad,'sexp',PP);%KRG(sampling,resp,grad,2,'sexp',MM,PP);
% kk=SVR;
% kk.addSample(sampling);
% kk.addResp(resp);
% kk.addGrad(grad);
%kk.polyOrder=1;
for ii=1:400
    [Z,GZ]=kk.eval(randn(1,3));
end

GZ=zeros(size(grad));
for ii=1:ns
    [Z(ii),GZ(ii,:),var]=kk.eval(sampling(ii,:));
end

all(abs(resp(:)-Z(:))<1e-7)
all(abs(grad(:)-GZ(:))<1e-7)
pause
for ii=1:100
nSnew=5;
samplingN=randn(nSnew,3);
respN=randn(nSnew,1);
gradN=randn(nSnew,3);
%
%MM.addData(samplingN,respN);%,[])
PP.estimOn=false;
kk.update(samplingN,respN);%,gradN)%,MM)

samplingTest=[sampling;samplingN];
respTest=[resp;respN];
gradTest=[grad;gradN];


GZ=zeros(size(gradTest));
for ii=1:ns+nSnew
    [Z(ii),GZ(ii,:),var]=kk.eval(samplingTest(ii,:));
end

all(abs(respTest(:)-Z(:))<1e-7)
all(abs(gradTest(:)-GZ(:))<1e-7)
end
