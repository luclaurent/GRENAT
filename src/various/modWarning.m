%% class for dealing with the display or not of the warning message
% KRG: kriging
% GKRG: cokriging w/- gradients
% L. LAURENT -- 10/08/2017 -- luc.laurent@lecnam.net

classdef modWarning
    properties (Access = private)
        initStatus;     % initial status obtained when the object is created
    end
    properties (Dependent)
        currentStatus;  %
    end
    methods
        %% constructor
        function obj=modWarning(requireStatus)
            obj.initStatus=warning;
            %if a specific status if requested manage it
            if nargin>=1
                obj.manageStatus(requireStatus);
            end
        end
        
        %% get the current status
        function cS=get.currentStatus(obj)
            cS=warning;
        end
        
        %% manage with requested status
        function manageStatus(obj,requireStatus)
            txtCmd='';
            %for different kinds of input command
            if islogical(requireStatus)
                if requireStatus
                    txtCmd='on';
                else
                    txtCmd='off';
                end
            elseif isnumeric(requireStatus)
                if requireStatus==0
                    txtCmd='off';
                else
                    txtCmd='on';
                end
            elseif ischar(requireStatus)
                txtCmd=requireStatus;
            end
            %for different keywords
            switch txtCmd
                case {'on','o','O','On','ON'}
                    obj.change('on');
                case {'off','f','F','Off','OFF'}
                    obj.change('off');
                case {'switch','s','Switch','SWITCH'}
                    obj.switchStatus;
            end
        end
        
        %% change status depending of the request
        function change(obj,requestIn)
            varW=obj.initStatus;
            varW.state=requestIn;
            warning(varW);
        end
        %% switch status
        function switchStatus(obj)
            if strcmp(obj.currentStatus.state,'on')
                obj.change('off');
            else
                obj.change('on');
            end
        end
        
        %% initialize the warning state
        function init(obj)
            warning(obj.initStatus);
        end
    end
    
end
