function connect(T,host,user,password)
% The IP switch would not strictly need a connect() method.
% This is added  merely for the convenience of allowing a separate
% 'create' and 'connect' configuration, like other LAST_Handle objects

    % if the connection parameters are given explicitely as additional
    %  arguments, they override eventual configuration or default values
    if exist('password','var')
        T.Password=password;
    end
    if exist('user','var')
        T.User=user;
    end
    if exist('host','var')
        T.Host=host;
        % set new weboptions only if any of the preceding three arguments has
        %  been passed (which implies at least Host). I suspect that doing
        %  it all the times may give transient errors, like in
        %  https://github.com/EastEriq/LAST_tinycontrolIPpowerSocket/issues/1
        %  https://github.com/EastEriq/LAST_tinycontrolIPpowerSocket/issues/3
        T.Options=weboptions('Username',T.User,'Password',T.Password,...
            'Timeout',T.Timeout);
        pause(1)
    end

    % load configuration (setting at most some new output values)
    T.PhysicalId=T.Name; % to allow the same naming mechanism as other drivers...
    T.loadConfig(T.configFileName('connect'))
    
end