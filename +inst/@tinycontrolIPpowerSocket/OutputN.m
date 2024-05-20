function o=OutputN(T,i,offon)
    % get the status of a single output if called with one numeric
    %  argument, sets it if it called with two (the second argument
    %  is a boolean for the state)
    if nargin==3
        try
            webwrite(T.makeUrl(sprintf('outs.cgi?out%d=%d',i-1,offon)),...
                 T.Options);
        catch
            T.reportError('writing state of output %d of switch %s failed, offline?',...
                i,T.Id);
        end
    end
    oo=T.Outputs;
    o=oo(i);
end
