function url=makeUrl(T,extra)
    if ~exist('extra','var')
        extra='';
    end
    url = sprintf('http://%s:%s@%s/%s',T.User,T.Password,T.Host,extra);
    end
