classdef tinycontrolIPpowerSocket < obs.LAST_Handle
    
    properties
        Outputs=false(1,6);  % power at each socket, false=OFF/true=ON
    end
    
    properties (Hidden)
        Host='192.168.1.100'; % ip or hostname
        User='admin'; % username for connecting, usually 'admin'
        Password='admin' % password for the controlling user (should match what flashed in the device)
    end
    
    % these properties are hidden because it takes time to retrieve them:
    properties (Hidden,SetAccess=private)
        MAC % mac address of the device
        Name % name of the device, as flashed from the webby config
        Options % weboptions() for web queries to the device, e.g. User, Password, Timeout
    end
    
    methods
        % creator
        function T=tinycontrolIPpowerSocket(id)
            if exist('id','var')
                T.Id=id;
            end
            % load configuration
            T.loadConfig(T.configFileName('create'))
        end
        
        % getters and setters
        function set.User(T,user)
            T.User=user;
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',1);
        end
        
        function set.Password(T,password)
            T.Password=password;
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',1);
        end
        
        function o=get.Outputs(T)
            try
                resp = webread(T.makeUrl('st0.xml'),T.Options);
                o=false(1,6);
                for i=1:6
                    o(i)=(resp(strfind(resp,sprintf('<out%d>',i-1))+6)=='1');
                end
            catch
                T.reportError(sprintf('reading status of switch %s failed, offline?',T.Id));
                o=[];
            end
        end
        
        function set.Outputs(T,outputs)
            try
                currentOutputs=T.Outputs;
                for i=1:min(numel(outputs),6)
                    if outputs(i) ~= currentOutputs(i)
                        webwrite(T.makeUrl(sprintf('outs.cgi?out%d=%d',i-1,outputs(i))),...
                            T.Options);
                    end
                end
            catch
                T.reportError(sprintf('setting status of switch %s failed, offline?',T.Id));
            end
        end
        
        function m=get.MAC(T)
            try
                boardpage=webread(T.makeUrl('board.xml'),T.Options);
                m=boardpage(strfind(boardpage,'<b6>')+4:strfind(boardpage,'</b6>')-1);
            catch
                T.reportError(sprintf('reading MAC of switch %s failed, offline?',T.Id));
                m=[];
            end
        end
        
        function n=get.Name(T)
            try
                boardpage=webread(T.makeUrl('board.xml'),T.Options);
                n=boardpage(strfind(boardpage,'<b7>')+4:strfind(boardpage,'</b7>')-1);
                % the retrieved name is 15 char long, right padded with spaces
                n=strtrim(n);
            catch
                T.reportError(sprintf('reading name of switch %s failed, offline?',T.Id));
                n=[];
            end
        end
        
    end
           
end