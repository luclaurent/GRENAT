%% check matrices
function f=checkMatrix(obj)
%check symetry
fS=all(all(obj.KK==obj.KK'));
%check eye
fE=all(diag(obj.KK)==1);
%check the adding process
KKold=obj.KK;
obj.sampling=[obj.sampling;obj.newSample];
obj.requireRun=true;
obj.requireIndices=true;
KKnew=obj.buildMatrix();
fA=all(all(KKold==KKnew));
%
f=(fS&&fE&&fA);
%
fprintf('Matrix ');
if f; fprintf('OK'); else, fprintf('NOK');end
fprintf('\n');
if ~f;keyboard;end
end