% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


disp('  This demo illustrates facilities of LS-SVMlab');
disp('  with respect to unsupervised learning.');

disp(' a demo dataset is generated...');
clear yin yang samplesyin samplesyang mema
% initiate variables and construct the data
nb = 25;
sig = .4;

% construct data
leng = 1;
for t=1:nb, 
  yin(t,:) = [2.*sin(t/nb*pi*leng) 2.*cos(.61*t/nb*pi*leng) (t/nb*sig)]; 
  yang(t,:) = [-2.*sin(t/nb*pi*leng) .45-2.*cos(.61*t/nb*pi*leng) (t/nb*sig)]; 
  samplesyin(t,:)  = [yin(t,1)+yin(t,3).*randn   yin(t,2)+yin(t,3).*randn];
  samplesyang(t,:) = [yang(t,1)+yang(t,3).*randn   yang(t,2)+yang(t,3).*randn];
end

% plot the data
figure; hold on
plot(samplesyin(:,1),samplesyin(:,2),'b+');
plot(samplesyang(:,1),samplesyang(:,2),'r*');
xlabel('X_1');
ylabel('X_2');
title('Structured dataset');
disp('  (press any key)');
pause

%
% kernel based Principal Component Analysis
%
disp('  extract the principal eigenvectors in feature space');
disp(' >> nb_pcs=5;'); nb_pcs = 5;
disp(' >> sig2 = .75;'); sig2 = .75;
disp(' >> [lam,U] = kpca([samplesyin;samplesyang],''RBF_kernel'',sig2,[],''eigs'',nb_pcs); ');
[lam,U] = kpca([samplesyin;samplesyang],'RBF_kernel',sig2,[],'eigs',nb_pcs);
disp('  (press any key)');
pause

%
% make a grid over the inputspace
%
disp(' make a grid over the inputspace:');
disp('>> Xax = -3:1:3; Yax = -3.2:1:3.2;'); Xax = -3:.2:3; Yax = -3.2:.2:3.2;
disp('>> [A,B] = meshgrid(Xax,Yax);'); [A,B] = meshgrid(Xax,Yax);
disp('>> grid = [reshape(A,prod(size(A)),1) reshape(B,1,prod(size(B)))'']; ');
grid = [reshape(A,prod(size(A)),1) reshape(B,1,prod(size(B)))'];


%
% compute projections of each point of the inputspace on the
% principal components
%
disp('  compute projections of each point of the inputspace on the  ');
disp('  principal components');
disp('>> k = kernel_matrix([samplesyin;samplesyang],''RBF_kernel'',sig2,grid)'';  ');
k = kernel_matrix([samplesyin;samplesyang],'RBF_kernel',sig2,grid)';
disp('>> projections = k*U;'); projections = k*U; 
disp('>> contour(Xax,Yax,reshape(projections(:,1),length(Yax),length(Xax)));'); 
contour(Xax,Yax,reshape(projections(:,1),length(Yax),length(Xax)));
title('projections of the inputspace on the principal components in feature space');
disp('  (press any key)');
pause



%
% minimize the reconstruction error using the first principal components
%
disp(' ');
disp(' Minimize the reconstruction error using the first principal components');


try
  disp(' Fo every point, the reconstruction point is minimzed using');
  disp(' ----------------------------------------------------------');
  disp(' ');
  disp('>> Xd = denoise_kpca([samplesyin;samplesyang],''RBF_kernel'',sig2,[],''eigs'',5); ');
  Xd = denoise_kpca([samplesyin;samplesyang],'RBF_kernel',sig2,[],'eigs',5); 
  disp('>> plot(Xd(:,1),Xd(:,2),''ko''); '); plot(Xd(:,1),Xd(:,2),'ko');
  disp(' ');
  title('Denoising (''o'') by minimizing the reconstruction error in feature space');
  disp(' ');
  disp(' In the last figure, one can see the original datapoints');
  disp('(''*'') and the reconstructed data (''o'').  ');
  disp(' ');
catch
  disp(' Denoising does not work when the ''fminunc'' function is unavailable ');
end
  disp(' ');
disp('  This  concludes this demo');
hold off 