

%% Show the result of the CV
function showCV(obj)
%use QQ-plot
opt.newfig=false;
figure;
subplot(1,3,1);
opt.title='Normalized data (CV R)';
QQplot(obj.resp,obj.cvResults.cvZR,opt);
subplot(1,3,2);
opt.title='Normalized data (CV F)';
QQplot(obj.resp,obj.cvResults.cvZ,opt);
subplot(1,3,3);
opt.title='SCVR (Normalized)';
opt.xlabel='Predicted' ;
opt.ylabel='SCVR';
SCVRplot(obj.cvResults.cvZR,obj.cvResults.scvrR,opt);
end
