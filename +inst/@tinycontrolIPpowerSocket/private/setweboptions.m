function setweboptions(T)
% called when changing User, Password or Timeout
% I got the copilot tip of not passing User and Password explicitely,
%  but to encode them in the Header authorization, to avoid a double 
%  http GET
    T.Options=weboptions('Timeout',T.Timeout,...
        'HeaderFields',{'Authorization', ...
        ['Basic ' matlab.net.base64encode([T.User ':' T.Password])]});
