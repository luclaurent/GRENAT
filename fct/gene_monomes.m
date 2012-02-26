%% Génération des monomes des polynomes (en fonction du degré et du nb de variables)
% L.LAURENT -- 25/02/2012 -- laurent@lmt.ens-cachan.Fr

clear all
% degré
degre=10;
% nb variables
dim=10;

%dossier de stockage
doss='base_monomes';
if exist(doss,'dir')~=7
    unix(['mkdir ' doss])
end

%fichier de stockage
file='mono';
ext='.m';

%stockage
mono1=cell(degre,dim);
monod1=mono1;
monod2=mono1;
cmonod1=mono1;
cmonod2=mono1;
%matlabpool(4)
for deg=1:degre
    for nbv=1:dim
        fprintf('deg = %i  dim = %i\n',deg,nbv)
       %valeurs pour chaques variables        
        val_var=cell(nbv,1);
        for ii=1:nbv
            val_var{ii}=uint8(0:deg);
            
        end
        nb_tir=(deg+1)*ones(1,nbv);
        
        % generation de la matrice des tirages
        % parcours des variables
        
        for ii=1:nbv
            if ii>1
                nb_ter_pre=prod(nb_tir(1:ii-1));
            else
                nb_ter_pre=1;
            end
            %parcours des valeurs par variables
            temp1=[];
            for jj=1:length(val_var{ii})
                temp=repmat(val_var{ii}(jj),nb_ter_pre,1);
                temp1=uint8([temp1;temp]);
            end
            temp2=repmat(temp1,prod(nb_tir(ii+1:end)),1);
            clear temp1 temp
            combinaison(:,ii)=temp2;
            clear temp2;
        end
        combinaison=uint8(combinaison);
        
        % génération combinaison
        %levels=(deg+1)*ones(1,nbv,'uint8');
        %combinaison=sparse(fullfact(levels)-1);
        %suppression ligne td sum term>deg
        ind=[];
        
        for cc=1:size(combinaison,1)
            if sum(combinaison(cc,:))>deg
                ind=[ind cc];
            end
        end
        %[ind]=find(sum(combinaison,2)>deg);
        monomes_pow=combinaison;
        clear combinaison
        %puissance monomes
        
        monomes_pow(ind,:)=[];
        clear ind
        %coef derivées première et monomes dérivées premières
        coef_der1=monomes_pow;
        monomes_der1=repmat(monomes_pow,1,nbv);
        for pp=1:nbv
            monomes_der1(:,(pp-1)*nbv+pp)=monomes_der1(:,(pp-1)*nbv+pp)-1;
        end
        
        for cc=1:numel(monomes_der1)
            if monomes_der1(cc)<0
                monomes_der1(cc)=0;
            end
        end
        %[ind]=find(monomes_der1<0);
        %monomes_der1(ind)=0;
        clear ind
        %coef derivées secondes et monomes dérivées secondes
        coef_der2=monomes_der1;
        monomes_der2=repmat(monomes_der1,1,nbv);
        for pp=1:nbv
            for oo=1:nbv
                indd=(oo-1)*nbv+(pp-1)*nbv+pp;
                monomes_der2(:,indd)=monomes_der2(:,indd)-1;
            end
        end
        for cc=1:numel(monomes_der2)
            if monomes_der2(cc)<0
                monomes_der2(cc)=0;
            end
        end
        %[ind]=find(monomes_der2<0);
        %monomes_der2(ind)=0;
        clear ind
        %sauvegarde résultats
        mono1{deg,nbv}=monomes_pow;
        monod1{deg,nbv}=monomes_der1;
        monod2{deg,nbv}=monomes_der2;
        cmonod1{deg,nbv}=coef_der1;
        cmonod2{deg,nbv}=coef_der2;
        clear combinaison comb_mod temp temp1 temp2 ind indd
        clear monomes_pow monomes_der1 monomes_der2 coef_der2 coef_der1
    end
end


%stockage des monomes
for ii=1:deg
    for jj=1:dim
        fonction=[file '_' num2str(ii,'%02i') '_' num2str(jj,'%03i')];
        fichier=[doss '/' fonction ext];
        fid=fopen(fichier,'w');
        fprintf(fid,'%s\n\n',['function [mono,nbmono,monod1,cmonod1,monod2,cmonod2]=' fonction '()']);
        fprintf(fid,'derprem=false;dersecond=false;\n');
        fprintf(fid,'if nargout>=4;derprem=true;end\n');
        fprintf(fid,'if nargout==6;dersecond=true;end\n\n');
        fprintf(fid,'mono=[\n');
        mat=mono1{ii,jj}';
        fprintf(fid,'%i ',mat(:)');
        fprintf(fid,'\n');
        fprintf(fid,'];\n');
        fprintf(fid,'nbmono=%i;\n\n',size(mat,2));
        fprintf(fid,'if derprem\n');
        fprintf(fid,'monod1=[\n');
        mat=monod1{ii,jj}';
        for ll=1:size(mat,1);
            fprintf(fid,'%i ',mat(ll,:));
            fprintf(fid,'\n');
        end
        fprintf(fid,'];\n');
        %fprintf(fid,'monod1=monod1;\n');
        fprintf(fid,'cmonod1=[\n');
        mat=cmonod1{ii,jj}';
        for ll=1:size(mat,1);
            fprintf(fid,'%i ',mat(ll,:));
            fprintf(fid,'\n');
        end
        fprintf(fid,'];\n');
        %fprintf(fid,'cmonod1=cmonod1'';\n');
        fprintf(fid,'end\n\n');
        fprintf(fid,'if dersecond\n');
        fprintf(fid,'monod2=[\n');
        mat=monod2{ii,jj}';
        for ll=1:size(mat,1);
            fprintf(fid,'%i ',mat(ll,:));
            fprintf(fid,'\n');
        end
        fprintf(fid,'];\n');
        %fprintf(fid,'monod2=monod2;\n');
        fprintf(fid,'cmonod2=[\n');
        mat=cmonod1{ii,jj}';
        for ll=1:size(mat,1);
            fprintf(fid,'%i ',mat(ll,:));
            fprintf(fid,'\n');
        end
        fprintf(fid,'];\n');
        %fprintf(fid,'cmonod2=cmonod2'';\n');
        fprintf(fid,'end\n\n');
        fprintf(fid,'end\n\n');
        
        fclose(fid);
    end
    
end
