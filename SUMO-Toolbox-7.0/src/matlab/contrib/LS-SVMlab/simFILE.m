function Ytest = simFILE(model, filename,Xt,Yt)
% Only for intern LS-SVMlab use;
%
% simulate the LS-SVM model using the FILE interface to the C-file;
% By default, the file 'buffer.mc' is used to pass the arguments.
%
% Yt = simFILE(model, filename,Xt)
%
% see simlssvm for use;
%

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%
% change to dir ~/matlab
%
%or_dir = pwd;
%cd ~/matlab/;


eval('Yt;','Yt=[];');

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
 
   
   
   % xtrain: rowwise   
   for j=1:model.nb_data,
     for i=1:model.x_dim,
       fwrite(fid,model.xtrain(model.selector(j),i), 'double');
     end
   end

   % ytrain: columnwise
   for i=1:model.y_dim
     for j=1:model.nb_data
       fwrite(fid,model.ytrain(model.selector(j),i), 'double');
     end
   end

   % write alpha's: columnwise   
   for i=1:model.y_dim
     for j=1:model.nb_data
       fwrite(fid,model.alpha(j,i), 'double');
     end
   end

   % write b
   for i=1:model.y_dim,
     fwrite(fid,model.b(i), 'double');
   end

   % Xtest: rowwise
   nxt = size(Xt,1);
   fwrite(fid,nxt, 'int');   
   for j=1:nxt,
     for i=1:model.x_dim,
       fwrite(fid,Xt(j,i), 'double');
     end
   end

   % Ytest: columnwise   
   nyt = size(Yt,1);
   fwrite(fid,nyt, 'int');   
   for i=1:model.y_dim,
       for j=1:nyt,
           fwrite(fid,Yt(j,i), 'double');
       end
   end

   
   fclose(fid);

% Compute alpha & b

% windows
%['!simFILE.exe ' filename]
%eval(['!simFILE.exe ' filename],'error(''error in C-executable, probably file ''lssvmFILE.x'' not found in current directory...'')');

% unix
status = unix(['simFILE.x ' filename]);
if status == 127, error('Executable ''simFILE.x'' not found in current directory'); end
if status~=0, error('something wrong'); end

% read results
fid=fopen(filename,'r');
nxt  = fread(fid,1,'int');
Yt  = fread(fid,model.y_dim*nxt,'double');
Ytest = reshape(Yt,length(Yt)/model.y_dim, model.y_dim);
fclose(fid);

%
% change original directory 
%
%cd(or_dir);
