function CS = smartindent (mfiles,indentfactor)
%SMARTINDENT smart indents m files.
%
%   syntax: CS = SMARTINDENT (mfiles,indentfactor)
%
%   INPUT ARGUMENT
%       - mfiles            string/cellstrings of m-file names. Partial path names
%                           are allowed;
%       - indentfactor      optional positive integer with the indentation factor.
%                           It determines the number of blanks used for the
%                           indentation. The default is 4.
%                           Positive rational will be substituted by the nearest int.
%
%   OUTPUT ARGUMENTS
%       - CS                optional cell array of strings containing the formatted strings.
%                            
%
%   SMARTINDENT correctly processes the executable lines of any m file, fully mimicking
%   the behaviour of the homonymous command of the Matlab editor. In-line and partial
%   in-line flow control statements are also handled; e.g.
%
%       if 'You want to indent your mfiles in batch mode'...
%       & 'simply don''t know how'
%       try 'SMARTINDENT &', catch 'up with your friends',...
%       end,'have fun',while 'it''ll do the dirty job...',for Y=O:U 'or,'
%       if 'you already have a tool,'
%       switch 'to SMARTINDENT or ', case 1, switch 'off your fancies' 
%       case 2, 'get serious about programming'
%       otherwise 'you''ll get caught in dire straits!!!'
%       end,end,end,end,end,end
%
%   SMARTINDENT resets the executable line's offsets at the beginning of the code,
%   that is, the first executable line does not have leading blanks and the remainder
%   is formatted from there.
%
%   SMARTINDENT prints a warning message on the command line if it gets troubles with
%   file I/O actions and does not suppress the execution flow for the remainder of
%   the file list to be processed. In this event, the output string associated to the
%   troublesome file is set to an empty string.
%
%   To process all files under a given folder(s), call SMARTINDENT with FUF,
%   e.g., to process all m files under folders ...\Documents and ...\MyFcns, type
%
%       >> SMARTINDENT(FUF({'...\Documents\*.m','...\MyFcns\*.m'}))
%
%   You can download FUF from the Matlab File Exchange under the category DEVELOPMENT ENVIRONMENT: the
%   submission name is "Files Under Folders".
%
%                           
%   REMARKS
%       - SMARTINDENT overwrite the files processed, so it is highly recommended that
%         you previously do a back up of your files.
%       - when invoked from the command line, SMARTINDENT worn the users to back up first their
%         files, whilst, when invoked from within another function, no warning is issues, thus
%         allowing for off-line multiple calls.

%                                         -$-$-$-
%
%  Author:       Francesco di Pierro        Dep. of Electronics and Computer Science (DEI)
%                                           Politecnico di Milano
%                                           e-mail: dipierro@elet.polimi.it
%
%                                         -$-$-$-

%------------------------------INPUT ARGUMENT CHECKING-------------------------%

error(nargchk(1,2,nargin));
error(nargoutchk(0,1,nargout));

if ~iscellstr(mfiles) & ~ischar(mfiles) 
    error('The first input parameter must be eigther a string or a cell array of strings!');
elseif ischar(mfiles)
    mfiles = {mfiles};
end
if nargin==1
    indentfactor = 4;
elseif ~isscalar(indentfactor) & ~isnumeric(indentfactor)
    error('The indentation factor must be a real scalar!');
elseif indentfactor<0
    error('Negative indentation factors not allowed!');
else
    indentfactor = round(indentfactor);
end
    
%-----------------------------END INPUT ARGUMENT CHECKING-------------------------%

ST = dbstack;                %if SMARTINDENT is called from within another function or script,...
if length(ST)==1             %it doesn't remind the user...
    answ = questdlg('SMARTINDENT will overwrite your files. Have you backed them up?','Warning','YES','NO','NO');
    if strcmp(answ,'NO')
        if nargout == 1
            CS = [];
        end
        return
    end
end    

w_status = warning;
warning on
S =[];
for i=1:length(mfiles)
    if exist(mfiles{i})==2
        f = which(mfiles{i});
        [fpath,fname,fext] = fileparts(f);
        if ~isempty(fext)
            if ~strcmp(fext,'.m')
                warning(['The file "',f,'" is not an m file']);
                S = [S;{''}];
                continue
            end
        else
            warning(['File "',f,'" not found']);
            S = [S;{''}];
            continue
        end
        s = textread(f,'%s','delimiter','\n');
        s = addindent(s,indentfactor);
        [fido,opmsg] = fopen(f,'w');
        if fido==-1
            warning(['Troubles when  opening "',f '": ',opmsg]);
            S = [S;{''}];
            continue
        end
        fprintf(fido,'%s\n',s{:});
        fidc = fclose(fido);
        if fidc==-1
            warning(['Troubles when  closing "',f '": ',ferror(fidc)]);
            S = [S;{''}];
            continue
        end
    else
        warning(['File "',mfiles{i},'" not found']);
        S = [S;{''}];
        continue
    end
    S = [S;{char(s)}];
end
if nargout == 1
    CS = S;
end
warning(w_status);

function s = addindent(s,indentfactor)

nextincrement_list = {'for','while','if','else','elseif','switch','case','otherwise','try','catch'};
currdecrement_list = {'else','elseif','case','otherwise','catch'};
nextdecrement_list = 'end';
spacenum = 0*ones(1,length(s));
for i=1:length(s)
    line = flipdim(deblank(flipdim(s{i},2)),2);
    line = strrep(line,',',' ');
    line = strrep(line,';',' ');
    if isempty(line)
        continue    
    elseif strcmp(line(1),'%')
        continue
    else 
        tokens = strread(line,'%[^ ]');
        isstr = 0;
        for j=1:length(tokens)
            [iscomm, isellipsis, isstr] = iscomment(tokens{j},isstr);
            if iscomm
                break
            elseif isellipsis
                if i~=length(s)
                    spacenum(i+1) = spacenum(i+1)+indentfactor;
                    break
                else
                    break
                end
            end
            if any(strcmp(tokens{j},nextincrement_list))
                if any(strcmp(tokens{j},currdecrement_list)) 
                    if j==1  
                        spacenum(i) = spacenum(i)-indentfactor;
                    end
                elseif i~=length(s)
                    spacenum(i+1:end) = spacenum(i+1:end)+indentfactor;   
                end
            elseif strcmp(tokens{j},nextdecrement_list)
                if j==1 
                    spacenum(i:end) = spacenum(i:end)-indentfactor;
                elseif i~=length(s)
                    spacenum(i+1:end) = spacenum(i+1:end)-indentfactor;
                end
            end
        end
    end
    s{i} = [blanks(spacenum(i)), s{i}];
end


function [iscomm, isellipsis, isstr] = iscomment(token,isstr)

dots = 0;
iscomm = 0;
isellipsis = 0;
for i=1:length(token)
    if token(i)==char(39)
        isstr= ~isstr;
        dots = 0;
    elseif token(i)=='%' & ~isstr
        iscomm = 1;
        break
    elseif token(i)=='.'
        dots = dots+1;
        if dots==3 & ~isstr
            isellipsis = 1;
            break
        end
    else
        dots = 0;
    end
end