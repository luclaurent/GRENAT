function exportToMFile(m,outputIndex,filename)

% exportToMFile (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 6376 $
%
% Signature:
%	exportToMFile(m,outputIndex,filename)
%
% Description:
%	Export the model to a standalone Matlab script (wrapping getExpression)

[numInputs numOutputs] = getDimensions(m);

if(any(outputIndex < 1) || any(outputIndex > numOutputs) || length(outputIndex) > numOutputs)
	error('Invalid output index given');
end


fid = fopen(filename,'w');
if(fid < 0)
	error(['Failed to open filename ' filename ' for writing'])
end


sumoVer = char(ibbt.sumo.config.ContextConfig.getToolboxVersion());
inputNames = getInputNames(m);
outputNames = getOutputNames(m);
outputName = outputNames(outputIndex);

outputVector = stringJoin(outputName,',');
paramVector = stringJoin(inputNames,',');

modelDesc = getDescription(m);
modelDesc = strrep(modelDesc,sprintf('\n'),sprintf('\n%%'));
modelVer = getVersion(m);

% build the function name from the filename
[pathstr,funcName,ext,ver] = fileparts(filename);

fprintf(fid,'function [%s] = %s(%s)',outputVector,funcName,paramVector);
fprintf(fid,'\n\n');
fprintf(fid,'%% Description\n');
fprintf(fid,'%%    Exported %s for output(s) %s, built with %d samples\n',class(m),outputVector,size(getSamples(m),1));
fprintf(fid,'%%    Model version: %s\n',modelVer);
fprintf(fid,'%%    Model Description: \n%%\n%%    %s\n%%\n',modelDesc);

% get the min-max ranges for each parameter
fprintf(fid,'%%    Parameter ranges:\n');
[LB UB] = getBounds(m);

for i=1:length(inputNames)
	fprintf(fid,'%%       %s : [%d,%d]\n',inputNames{i},LB(i),UB(i));
end

fprintf(fid,'%%\n%%    Global model score: %d\n',getScore(m));
fprintf(fid,'%%\n%%    Measure scores:\n');

mes = getMeasureScores(m);
% TODO for backwards compatability
if(isstruct(mes))
    mes = mes.measureInfo;
end

% loop over every output
for k=1:length(outputIndex)
  
  if(isempty(mes)) break; end
      
  ms = mes{k};

  % loop over every measure
  for i=1:length(ms)

	  fprintf(fid,'%%\n%%    Output : %s\n',outputNames{k});

	  if(ms{i}.enabled)
		  fprintf(fid,'%%\n%%       Measure : %s\n',ms{i}.type);
	  else
		  fprintf(fid,'%%       Measure : %s (off)\n',ms{i}.type);
	  end

	  fprintf(fid,'%%       Error fcn : %s\n',ms{i}.errorFcn);
	  fprintf(fid,'%%       Score     : %d\n',ms{i}.score);
	  
	  fprintf(fid,'%');
  end

  fprintf(fid,'%%\n');
end

fprintf(fid,'%%\n');
fprintf(fid,'%%    WARNING: the conversion to a string expression may have resulted in some lost precision!');
fprintf(fid,'\n%%\n');
fprintf(fid,'%%    This file was generated on %s by the SUMO Toolbox version %s\n',date,sumoVer);
fprintf(fid,'%%    Contact: sumo@intec.ugent.be - www.sumo.intec.ugent.be');
fprintf(fid,'\n\n');

fprintf(fid,'%% This is the result of calling getExpression() on the model:\n\n');

% handle the first output
expression = getExpression(m,outputIndex(1));
fprintf(fid,expression);
fprintf(fid,'\n\n');

% do the rest (without the scaling)

for i=2:length(outputIndex)
  expression = getExpressionInModelSpace(m,outputIndex(i));
  fprintf(fid,sprintf('%s = %s;', outputNames{outputIndex(i)},expression));
  fprintf(fid,'\n\n');
end

fclose(fid);
