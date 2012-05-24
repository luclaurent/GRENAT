%procédure de calcul CV pour debug

function [cv]=cross_validate_rbf(data_block,data,meta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Methode de Rippa
es=data_block.build.w./diag(data_block.build.iKK);
diag(data_block.build.iKK)
%es
data_block.build.w
if data.in.pres_grad
    esr=es(1:data.in.nb_val);
    esg=es((data.in.nb_val+1):end);
    eloot=1/(data.in.nb_val*(data.in.nb_var+1))*(es'*es);
    eloor=1/data.in.nb_val*(esr'*esr);
    eloog=1/(data.in.nb_val*data.in.nb_var)*(esg'*esg);
else
    eloot=1/(data.in.nb_val)*(es'*es);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Methode classique (construction de nb_val metamodeles en retirant
%%% reponses et gradients
for tir=1:data.in.nb_val
    if data.in.pres_grad
        pos=[tir data.in.nb_val+(tir-1)*data.in.nb_var+(1:data.in.nb_var)];
    else
        pos=tir;
    end
    
    %retrait
    cv_y=data.build.y;
    cv_KK=data_block.build.KK;
    cv_y(pos,:)=[];
    cv_KK(pos,:)=[];
    cv_KK(:,pos)=[];
%     pos
%     cv_y
%     data.in.eval
%     data.in.grad
    cv_w=inv(cv_KK)*cv_y;
%     cv_w
%     data_block.build.w
    cv_tirages=data.in.tirages;
    cv_tirages(tir,:)=[];
    
    donnees_cv=data;
    donnees_cv.build.fct=data_block.build.fct;
    donnees_cv.build.para=data_block.build.para;
    donnees_cv.build.w=cv_w;
    donnees_cv.build.KK=cv_KK;
    donnees_cv.in.nb_val=data.in.nb_val-1;
    
    donnees_cv.in.tiragesn=cv_tirages;
    
    [Z,GZ,variance]=eval_rbf(data.in.tirages(tir,:),donnees_cv);
    cv_Z(tir)=Z;
    cv_GZ(tir,:)=GZ;
    cv_var(tir)=variance;
    
end

%%calcul de la variance
for tir=1:data.in.nb_val
        if data.in.pres_grad
        pos=[tir data.in.nb_val+(tir-1)*data.in.nb_var+(1:data.in.nb_var)];
    else
        pos=tir;
    end
    PP=data_block.build.KK(:,tir);
    ret_KK=data_block.build.KK;
    ret_KK(pos,:)=[];
    ret_KK(:,pos)=[];
    PP(pos)=[];
    var(tir)=1-PP'*inv(ret_KK)*PP;
    
end
fprintf('variance\n')
[cv_var' var']
pause


cv_Z=cv_Z';
diff=cv_Z-data.in.eval;
diffc=diff.^2;
if data.in.pres_grad
    cv_GZ=cv_GZ;
    diffg=cv_GZ-data.in.grad;
    diffgc=diffg.^2;
end

if data.in.pres_grad
    class_eloot=1/(data.in.nb_val*(data.in.nb_var+1))*(sum(diffc(:))+sum(diffgc(:)));
    
    class_eloor=1/(data.in.nb_val)*sum(diffc(:));
    class_eloog=1/(data.in.nb_val*data.in.nb_var)*sum(diffgc(:));
else
    class_eloot=1/(data.in.nb_val)*sum(diffc(:));
end


% class_eloot
% eloot
% if data.in.pres_grad
%     sum(diffc(:))+sum(diffgc(:))
%     es'*es
%     [diff,esr]
%     class_eloor
%     eloor
%     class_eloog
%     eloog
% end
% pause


cv.loot=class_eloot;