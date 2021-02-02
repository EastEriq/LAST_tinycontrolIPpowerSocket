classdef tinycontrolIPpowerSocket < obs.LAST_Handle
    
    properties
        Host='192.168.1.100'; % ip or hostname
        User='admin'; % username for connecting, usually 'admin'
        Password='admin' % password for the controlling user (should match what flashed in the device)
        Outputs=false(1,6);  % power at each socket, false=OFF/true=ON
    end
    
    properties (Hidden)
        Options % weboptions() for web queries to the device, e.g. User, Password, Timeout
    end
    
    % these properties are hidden because it takes time to retrieve them:
    properties (Hidden,SetAccess=private)
        MAC % mac address of the device
        Name % name of the device, as flashed from the webby config
    end
    
    methods
        % creator
        function T=tinycontrolIPpowerSocket(host,user,password)
            if nargin>0
                T.Host=host;
            end
            if nargin>1
                T.User=user;
            end
            if nargin>2
                T.Password=password;
            end
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',1);
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
            resp = webread(T.makeUrl('st0.xml'),T.Options);
            o=false(1,6);
            for i=1:6
                o(i)=(resp(strfind(resp,sprintf('<out%d>',i-1))+6)=='1');
            end
        end
        
        function set.Outputs(T,outputs)
            currentOutputs=T.Outputs;
            for i=1:min(numel(outputs),6)
                if outputs(i) ~= currentOutputs(i)
                    webwrite(T.makeUrl(sprintf('outs.cgi?out%d=%d',i-1,outputs(i))),...
                             T.Options);
                end
            end
        end
        
        function m=get.MAC(T)
            boardpage=webread(T.makeUrl('board.xml'),T.Options);
            m=boardpage(strfind(boardpage,'<b6>')+4:strfind(boardpage,'</b6>')-1);
        end
        
        function n=get.Name(T)
            boardpage=webread(T.makeUrl('board.xml'),T.Options);
            n=boardpage(strfind(boardpage,'<b7>')+4:strfind(boardpage,'</b7>')-1);
        end
        
    end
           
end