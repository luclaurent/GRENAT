% configure (SUMO)
%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
%     Copyright: IBBT - IBCN - UGent
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
%
% Description:
%     Sets up the toolbox path

warning off

% get location of this file (toolbox root path)
p = mfilename('fullpath');
SUMORoot = p(1:end-9);

% add java paths
javaaddpath([SUMORoot fullfile('bin','java')]);
javaaddpath([SUMORoot fullfile('lib','jmf.jar')]);
javaaddpath([SUMORoot fullfile('lib','dom4j-1.6.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','jaxen-1.1.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','kd.jar')]);
javaaddpath([SUMORoot fullfile('lib','trilead-ssh2-build213.jar')]);
javaaddpath([SUMORoot fullfile('lib','jfreechart-1.0.11.jar')]);
javaaddpath([SUMORoot fullfile('lib','jcommon-1.0.14.jar')]);
javaaddpath([SUMORoot fullfile('lib','swing-layout-1.0.3.jar')]);

javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-graphics2d-2.1.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-graphicsio-2.1.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-graphicsio-ps-2.1.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-graphicsio-pdf-2.1.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-util-2.0.2.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-io-2.0.2.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-graphicsio-svg-2.1.1.jar')]);
javaaddpath([SUMORoot fullfile('lib','vectorgraphics-2.1.1','freehep-xml-2.1.1.jar')]);

% add matlab class paths
addpath(SUMORoot);
addpath(genpath([SUMORoot fullfile('src','matlab','')]));
addpath(genpath([SUMORoot fullfile('src','scripts','matlab','')]));

% workaround for jpegimages2movie
try
    com.sun.media.util.Registry.set('secure.allowSaveFileFromApplets', true);
catch err
    % happens if jmf is not present, ignore
end

disp('* The SUMO-Toolbox path has been setup...');
disp('* To get started see http://www.sumowiki.intec.ugent.be/index.php/Running');
