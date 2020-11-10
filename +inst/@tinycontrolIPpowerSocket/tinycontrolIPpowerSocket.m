classdef tinycontrolIPpowerSocket < handle
    
    properties
        host='192.168.1.100'; % ip or hostname
        user='admin';
        password='admin'
        outputs=false(1,6);  % power at each socket, off/on
    end
    
    properties (Hidden)
        options
    end
    
    methods
        % creator
        function T=tinycontrolIPpowerSocket(host,user,password)
            if nargin>0
                T.host=host;
            end
            if nargin>1
                T.user=user;
            end
            if nargin>2
                T.password=password;
            end
            T.options=weboptions('Username',T.user,'Password',T.password,...
                                 'Timeout',1);
        end
        
        % getters and setters
        function o=get.outputs(T)
            url = sprintf('http://%s:%s@%s',T.user,T.password,T.host);
            resp = webread([url '/st0.xml'],T.options);
            o=false(1,6);
            for i=1:6
                o(i)=(resp(strfind(resp,sprintf('<out%d>',i-1))+6)=='1');
            end
        end
        
        function set.outputs(T,outputs)
            url = sprintf('http://%s:%s@%s',T.user,T.password,T.host);
            for i=1:min(numel(outputs),6)
                webwrite([url,sprintf('/outs.cgi?out%d=%d',i-1,outputs(i))],T.options);
            end
        end
    end
end