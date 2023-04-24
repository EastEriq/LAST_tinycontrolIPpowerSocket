function success=disconnect(T)
% delete the Http client as disconnection
    try
        if T.Connected
            delete(T.HttpClient);
        end
        success=true;
    catch
        success=false;
    end

