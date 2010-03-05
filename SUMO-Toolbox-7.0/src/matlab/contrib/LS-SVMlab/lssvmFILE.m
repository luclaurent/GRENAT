function model = lssvmFILE(model, filename)
% Only for intern use of LS-SVMlab;
%
% calculate LS-SVM in performant C code;
% the parameters are given to the independent c-program by means of
% a file; This ensures robustness in future MATLAB versions.
%
% model = lssvmFILE(model, filename)
%
% WARNING: CHECK IF THE EXECUTABLE 'lssvmFILE.x' IS IN THE CURRENT
% DIRECTORY.  
%
% for use, see trainlssvm
%

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%
% change to dir ~/matlab
%
or_dir = pwd;
%cd ~/matlab/;


% save the parameters to file 

   fid=fopen(filename,'wb');
   fwrite(fid,model.type(1),'char');
   fwrite(fid,model.nb_data,'int');
   fwrite(fid,model.x_dim  ,'int');
   fwrite(fid,model.y_dim,'int');
   
   fwrite(fid,length(model.kernel_pars) ,'int');
   for t=1:length(model.kernel_pars),
     fwrite(fid,model.kernel_pars(t) ,'double');
   end
   
   lk = length(model.kernel_type);
   fwrite(fid,lk,'int');
   fprintf(fid,'%s',model.kernel_type);
   
   eval('dyn_pars = [model.steps; model.x_delays];','dyn_pars=[];');
   eval('dyn_pars = [dyn_pars;model.y_delays];',' ');
   fwrite(fid,length(dyn_pars) ,'int');
   for t=1:length(dyn_pars),
     fwrite(fid,dyn_pars(t) ,'int');
   end
   
   fwrite(fid,model.gam,'double');
   
   fwrite(fid,model.cga_eps  ,'double');
   fwrite(fid,model.cga_fi_bound  ,'double');
   fwrite(fid,model.cga_max_itr  ,'int');

   for i=1:model.nb_data
     for j=1:model.x_dim
       fwrite(fid,model.xtrain(model.selector(i),j), 'double');
     end
   end

   for i=1:model.y_dim
       for j=1:model.nb_data
	 fwrite(fid,model.ytrain(model.selector(j),i), 'double');
       end
   end

   eval('model.cga_startvalues;','model.cga_startvalues=[];');
   fwrite(fid,length(model.cga_startvalues)  ,'int');   
   for i=1:length(model.cga_startvalues),
     fwrite(fid,model.cga_startvalues(i), 'double');
   end

   fwrite(fid,model.cga_show, 'int');

   fclose(fid);

% Compute alpha & b
%  eval(['!lssvmFILE.x ' filename],'warning(CHECK IF THE EXE ''lssvmFILE.x'' is in the current directory');
%  eval(['!lssvmFILE.exe ' filename],'warning(CHECK IF THE EXE ''lssvmFILE.x'' is in the current directory');


%Read the result from mofe.out
   fid=fopen(filename,'r');
   model.nb_data = fread(fid,1,'int');
   model.y_dim   = fread(fid,1,'int');
   model.b     = fread(fid,model.y_dim,'double');
   model.alpha  = fread(fid,model.y_dim*model.nb_data,'double');
   model.alpha = reshape(model.alpha,length(model.alpha)/model.y_dim, model.y_dim);
   ssv = fread(fid,1,'int');
   model.cga_startvalues = fread(fid,ssv,'double');
   fclose(fid);


cd(or_dir);