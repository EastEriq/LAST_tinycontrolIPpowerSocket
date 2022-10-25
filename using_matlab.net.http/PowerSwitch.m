%
% A class for handling the Tiny Control Power Switches used in the LAST
%  project
%

%
% Future enhancement:
%  The methods should accept socketNames in addition to socketNumbers
%    e.g. turnOff('CameraNE') ot toggle('FocuserSW')
%

% Document:
%   https://tinycontrol.pl/media/documents/manual_IP_Power_Socket__6G10A_v2_LANLIS-010-015_En-1.pdf
%


classdef PowerSwitch
    
    properties
        Url;
    end
        
    methods
        function obj = PowerSwitch(address)
            arguments
                address string;
            end
            obj.Url = sprintf("http://%s", address);
        end
                
        function tf = isOff(X, socketNumber)
            tf = ~isOn(X, socketNumber);
        end
        
        function tf = isOn(X, socketNumber)
            xml = getPage(X, 'st0.xml');
            
            startElement = sprintf('<out%d>', socketNumber);
            endElement = sprintf('</out%d>', socketNumber);
            xml = extract(xml, startElement + digitsPattern(1) + endElement);
            pats = extract(xml, digitsPattern(1));
            tf = pats{2} == '1';
        end
        
        function toggle(X, socketNumber)
            X.getPage(sprintf("outs.cgi?out=%d", socketNumber));
        end

        function turnOn(X, socketNumber)
            X.getPage(sprintf("outs.cgi?out%d=1", socketNumber));
        end
        
        function turnOff(X, socketNumber)
            X.getPage(sprintf("outs.cgi?out%d=0", socketNumber));
        end

        function xml = getPage(X, page)
            Cred = matlab.net.http.Credentials(...
                'Username', 'admin', ...
                'Password', 'admin', ...
                'Scheme',   'Basic'  ...
                );

            Opts = matlab.net.http.HTTPOptions(...
                'Credentials',      Cred, ...
                'ConvertResponse',  true, ...
                'UseProxy',         false ...
                );

            if ~startsWith(page, "/")
                page = strcat("/", page);
            end
            Uri = matlab.net.URI(strcat(X.Url, page));

            Request = matlab.net.http.RequestMessage();
            Request.Method = 'GET';

            Response = Request.send(Uri, Opts);
            if Response.StatusCode == matlab.net.http.StatusCode.OK    
                xml = Response.Body.string;
            else
                error('PowerSwitch:getPage(%s) Error: %s', Uri.char, Response.StatusLine);
            end
        end
    end
end
