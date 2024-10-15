function queryCallback(T)
% callback function, used to perform a noniterruptible http query
% The result of the query (controller response, or errors) is stored in
%  T.HttpReply, which is visible in any context
T.HttpReply = webread(T.makeUrl(T.QueryHttpPage),T.Options);