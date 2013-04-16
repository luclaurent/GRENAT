version=2

switch version
    case 1

        doss_extract='CST2012/';
        exten='.dat';
        erreurZ = abs(Z.Z(:)-K.Z(:));

        erreurGZ = abs(Z.GZ(:)-K.GZ(:));

        data=[grid_XY(:) Z.Z(:)];
        save([doss_extract '1D_ref' exten],'data','-ASCII');

        data=[grid_XY(:) Z.GZ(:)];
        save([doss_extract '1D_G_ref' exten],'data','-ASCII');

        data=[grid_XY(:) erreurZ(:)];
        save([doss_extract '1D_' meta.type '_errZ' exten],'data','-ASCII');

        data=[grid_XY(:) erreurGZ(:)];
        save([doss_extract '1D_' meta.type '_errGZ' exten],'data','-ASCII');

        data=[grid_XY(:) K.Z(:)];
        save([doss_extract '1D_' meta.type exten],'data','-ASCII');

        data=[grid_XY(:) K.GZ(:)];
        save([doss_extract '1D_G_' meta.type exten],'data','-ASCII');

        data=[tirages eval];
        save([doss_extract '1D_eval' exten],'data','-ASCII');

        data=[tirages grad];
        save([doss_extract '1D_grad' exten],'data','-ASCII');
        
    case 2
        vvsave=[grid_XY',Z.Z',K.Z',K.var',ic68.inf',ic68.sup',ic95.inf',...
            ic95.sup',ic99.inf',ic99.sup'];
        vvsaveb=[[grid_XY';grid_XY(end:-1:1)'],[ic68.inf';ic68.sup(end:-1:1)'],...
            [ic95.inf';ic95.sup(end:-1:1)'],[ic99.inf';ic99.sup(end:-1:1)']];
        doss_extract='.';
        exten='.dat';
        
        switch meta.type
            case {'RBF','GRBF','InRBF'}
                fct=meta.rbf;
            case {'KRG','CKRG','InKRG'}
                fct=meta.corr;                
        end
        
        fichdeb=['1D_' meta.type '_' fct '_' num2str(prod(doe.nb_samples(:))) 'pt'];
        fichier=[fichdeb exten];
        fichierb=[fichdeb '_ic' exten];
        save(fichier,'vvsave','-ascii')
        save(fichierb,'vvsaveb','-ascii')
end