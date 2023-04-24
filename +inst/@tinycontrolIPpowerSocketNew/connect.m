function connected=connect(T)
% The IP switch would not strictly need a connect() method.
% This is added  merely for the convenience of allowing a separate
% 'create' and 'connect' configuration, like other LAST_Handle objects

    L=obs.api.Locator('Location',T.Id,'SetDriver',false);
    T.HttpClient=obs.api.HttpClient('Locator',L, 'User',T.User, ...
                                    'Password',T.Password, 'Timeout',T.Timeout);

    try
        % getting the name is a proof that we are connected
        T.PhysicalId=T.Name; % to allow the same naming mechanism as other drivers...
        connected=true;
        % load configuration (setting at most some new output values)
        T.loadConfig(T.configFileName('connect'))
    catch
        connected=false;
    end
    
end