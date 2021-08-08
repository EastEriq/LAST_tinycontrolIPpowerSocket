function connect(T,host,user,password)
% The IP switch would not strictly need a connect() method.
% This is added  merely for the convenience of allowing a separate
% 'create' and 'connect' configuration, like other LAST_Handle objects

    % load configuration
    T.loadConfig(T.configFileName('connect'))
    
    % if the connection parameters are given explicitely as additional
    %  arguments, they override eventual configuration or default values
    if exist('host','var')
        T.Host=host;
    end
    if exist('user','var')
        T.User=user;
    end
    if exist('password','var')
        T.Password=password;
    end

    T.Options=weboptions('Username',T.User,'Password',T.Password,...
        'Timeout',1);
end