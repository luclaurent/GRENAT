%procedure de calcul de score de tirages
% L. LAURENT -- 19/12/2012 -- laurent@lmt.ens-cachan.fr

function [uniform,discrepance]=score_doe(tirages)

%nombre de points
nb_val=size(tirages,1);
nb_var=size(tirages,2);


%generation des combinaison
comb=fullfact([nb_val nb_val]);
comb1=comb(:,1);comb2=comb(:,2);
diff=comb1-comb2;
ind=diff~=0;
comb1=comb1(ind);
comb2=comb2(ind);

%calcul des distances interpoints
pti=tirages(comb1,:);
ptj=tirages(comb2,:);
%reorganisation
pti=reshape(pti',nb_var,nb_val-1,nb_val);
ptj=reshape(ptj',nb_var,nb_val-1,nb_val);
ind=[2 1 3];
pti=permute(pti,ind);
ptj=permute(ptj,ind);
dist=sum((ptj-pti).^2,2).^.5;
%distance mini en chaque point
min_dist_pt=min(dist);
%distance mini moyenne en chaque point
min_dist_moy=mean(min_dist_pt);
%distance mini (maximin)
uniform.dist_min=min(min_dist_pt);
%somme inverse distance Leary et al. 2004
uniform.sum_dist=sum(1./dist(:));
%%critères issus de La thèse de Jessica FRANCO 2008
%mesure de recouvrement/uniformité
uniform.recouv=1/min_dist_moy*...
    (1/nb_val*sum(min_dist_pt-min_dist_moy)^2)^.5;
%rapport des distance
uniform.rap_dist=max(min_dist_pt)/min(min_dist_pt);
%distance min moyenne
uniform.avg_min_dist=min_dist_moy;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Discrepances
%(formules issues de Fang et al., Uniform Design: Theory and Application
%2000 & du manuscrit de these de Jessica Franco)

if nargout>=2
    %preparation
    tirm=reshape(tirages,nb_val,1,nb_var);
    tirm=repmat(tirm,[1 nb_val 1]);
    ind=[2 1 3];
    tirmb=permute(tirm,ind);
    tirm5=tirm-0.5;
    tirmb5=tirmb-0.5;
    
    % L2-discrepancy
    part1=prod(1-tirages.^2,2);
    maxtir=max(tirm,tirmb);
    prodm=prod(1-maxtir,3);
    part2=sum(prodm(:));
%     part2=0;
%     for ii=1:nb_val
%         for jj=1:nb_val
%             tmp=1;
%             for ll=1:nb_var
%                 tmp=tmp*(1-max(tirages(ii,ll),tirages(jj,ll)));
%             end
%             part2=part2+tmp;
%         end
%     end
    
    discrepance.L2=3^(-nb_var)-...
        2^(1-nb_var)/nb_val*sum(part1)...
        +1/nb_val*part2;
    
    % Centered L2-discrepancy
    part1=prod(1+0.5*abs(tirages-0.5)-0.5*(tirages-0.5).^2,2);
    opt=1+0.5*abs(tirm5)+0.5*abs(tirmb5);
    prodm=prod(opt,3);
    part2=sum(prodm(:));
%     part2=0;
%     for ii=1:nb_val
%         for jj=1:nb_val
%             tmp=1;
%             for ll=1:nb_var
%                 tmp=tmp*(1+0.5*abs(tirages(ii,ll)-0.5)+...
%                     0.5*abs(tirages(jj,ll)-0.5));
%             end
%             part2=part2+tmp;
%         end
%     end

    
    discrepance.CL2=(13/12)^nb_var-2/nb_val*sum(part1)+...
        1/nb_val^2*part2;
    
    % Symetric L2-discrepancy
    part1=prod(1+2*tirages-2*tirages.^2,2);
    opt=1+0.5*abs(tirm5)+0.5*abs(tirmb5)-...
        0.5*abs(tirm5-tirmb5);
    prodm=prod(opt,3);
    part2=sum(prodm(:));
%     part2=0;
%     for ii=1:nb_val
%         for jj=1:nb_val
%             tmp=1;
%             for ll=1:nb_var
%                 tmp=tmp*(1+0.5*abs(tirages(ii,ll)-0.5)+...
%                     0.5*abs(tirages(jj,ll)-0.5)-...
%                     0.5*abs(tirages(ii,ll)-tirages(jj,ll)));
%             end
%             part2=part2+tmp;
%         end
%     end
    
    discrepance.SL2=(4/3)^nb_var-...
        2/nb_val*sum(part1)+...
        2^nb_var/nb_val^2*part2;
    
    % Modified L2-discrepancy
    part1=prod(3-tirages.^2,2);
    opt=1-abs(tirm-tirmb);
    prodm=prod(opt,3);
    part2=sum(prodm(:));
%     part2=0;
%     for ii=1:nb_val
%         for jj=1:nb_val
%             tmp=1;
%             for ll=1:nb_var
%                 tmp=tmp*(1-abs(tirages(ii,ll)-tirages(jj,ll)));
%             end
%             part2=part2+tmp;
%         end
%     end
    discrepance.ML2=(4/3)^nb_var-...
        2^(1-nb_var)/nb_val*sum(part1)+...
        1/nb_val^2*part2;
    
    % wrap around L2-discrepancy
    part1=abs(tirm-tirmb);
    opt=3/2-part1.*(1-part1);
    prodm=prod(opt,3);
    part2=sum(prodm(:));
    discrepance.WL2=nb_val*(-(4/3)^nb_var+...
        1/nb_val^2*part2);
    
    
end
