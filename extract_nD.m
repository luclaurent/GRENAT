

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