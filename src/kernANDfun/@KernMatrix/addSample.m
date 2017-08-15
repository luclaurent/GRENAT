%add new sample points
function flag=addSample(obj,newS)
flag=false;
%remove dulicate
[~,l,~]=unique(newS,'rows');
newS=newS(sort(l),:);
%flag at true if duplicate sample points are removed
if size(newS,1)==numel(l);flag=true;end
%check if new sample point already exists
[~,Ln]=ismember(obj.sampling,newS,'rows');
%
Ln=Ln(Ln>0);
if ~isempty(Ln)
    fprintf(' >> Duplicate sample points detected: remove it\n');
    newS(Ln,:)=[];
end
obj.newSample=newS;
%%keyboard
if ~isempty(obj.newSample)
    obj.requireUpdate=true;
end
end