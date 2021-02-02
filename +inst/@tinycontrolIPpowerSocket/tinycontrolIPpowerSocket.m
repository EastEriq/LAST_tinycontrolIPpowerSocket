classdef tinycontrolIPpowerSocket < obs.LAST_Handle
    
    properties
        Host='192.168.1.100'; % ip or hostname
        User='admin';
        Password='admin'
        Outputs=false(1,6);  % power at each socket, off/on
    end
    
    properties (Hidden)
        Options % weboptions() for web queries to the device, e.g. User, Password, Timeout
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
 
    end
           
end