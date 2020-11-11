function o=OutputN(T,i,offon)
    % get the status of a single output if called with one numeric
    %  argument, sets it if it called with two (the second argument
    %  is a boolean for the state)
    if nargin==3
        webwrite(T.makeUrl(sprintf('outs.cgi?out%d=%d',i-1,offon)),...
                 T.Options);
    end
    oo=T.Outputs;
    o=oo(i);
end
