function resp=webquery(T,page)
% get the specified page of the switch, using either a direct call to
% webread or a timer callback, in order to provide message resource lockout
% (same principle as used in CelestronFocuser and XerxesBinary)
    ds=dbstack;
    callchain={ds.name};
    calledFromCallback = any(contains(callchain,{'timercb','instrcb'}));

    if calledFromCallback
        % call directly the monolithic query
        T.reportDebug('** calling monolithic query, from callback\n');
        resp = webread(T.makeUrl(page),T.Options);
    else
        % call it via a callback, so that it is uninterruptible.
        % Using T.QueryHttpPage and T.HttpReply to exchange data with the
        %  callback
        T.reportDebug('** calling monolithic query, from code\n');
        T.QueryHttpPage=page;
        start(T.HttpCollector); stop(T.HttpCollector);
        resp=T.HttpReply;
     end
