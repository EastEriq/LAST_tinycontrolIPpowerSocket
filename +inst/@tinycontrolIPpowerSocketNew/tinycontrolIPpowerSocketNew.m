classdef tinycontrolIPpowerSocketNew < obs.LAST_Handle
    
    properties (Description='api')
        Connected; % untyped, because the setter may receive a logical or a string
    end

    properties (Description='api,must-be-connected')
        Outputs=false(1,6);  % power at each socket, false=OFF/true=ON
    end

    properties(SetAccess=private,Description='api,must-be-connected')
        Sensors % 1-wire sensors and board temperature
    end

    properties (Hidden)
        HttpClient; % the obs.api.HttpClient object responsible for transport
        Host='192.168.1.100'; % ip or hostname
        User='admin'; % username for connecting, usually 'admin'
        Password='admin' % password for the controlling user (should match what flashed in the device)
    end

    % these properties are hidden because it takes time to retrieve them:
    properties (Hidden,SetAccess=private)
        MAC % mac address of the device
        Name % name of the device, as flashed from the webby config
    end

    properties (Hidden, Constant)
        Timeout=2; % timeout for webreads, in seconds
    end

    methods
        % creator
        function T=tinycontrolIPpowerSocketNew(Locator)
            % Now REQUIRES locator. Think at implications
            if exist('Locator','var') 
                if isa(Locator,'obs.api.Locator')
                    id = Locator.CanonicalLocation;
                else
                    id=Locator;
                end
            else
                id='';
            end
            % load configuration (including Host, [user, [password]])
            T.loadConfig(T.configFileName('create'))
            % fill initial status of untyped .Connected
            T.Connected=false;
            T.HttpClient=obs.api.HttpClient('Location',id, ...
                'User',T.User, 'Password',T.Password, 'Timeout',T.Timeout);

        end

        function delete(T)
            if T.Connected
                T.disconnect;
        % destructor, allowing for a shutdown status
            % Better not. For some reason an old object may be
            %  deleted after a new one is created, causing the
            %  shutdown config to be enforced just after the same
            %  device is turned on
            % T.loadConfig(T.configFileName('destroy'))
            end
        end


        % getters and setters

        function o=get.Outputs(T)
            try
                resp = h.GET('PAGE','st0.xml');
                o=false(1,6);
                for i=1:6
                    o(i)= resp(sprintf('out%d',i-1))=='1';
                end
                T.LastError='';
            catch
                T.reportError('reading status of switch %s failed, offline?',T.Id);
                o=[];
            end
        end

        function set.Outputs(T,outputs)
            try
                currentOutputs=T.Outputs;
                for i=1:min(numel(outputs),6)
                    if outputs(i) ~= currentOutputs(i)
                        webwrite(T.makeUrl(sprintf('outs.cgi?out%d=%d',i-1,outputs(i))),...
                            T.Options);
                    end
                end
                T.LastError='';
            catch
                T.reportError('setting status of switch %s failed, offline?',T.Id);
            end
        end

        function m=get.MAC(T)
            try
                boardpage=webread(T.makeUrl('board.xml'),T.Options);
                m=boardpage(strfind(boardpage,'<b6>')+4:strfind(boardpage,'</b6>')-1);
                T.LastError='';
            catch
                T.reportError('reading MAC of switch %s failed, offline?',T.Id);
                m=[];
            end
        end

        function n=get.Name(T)
            try
                boardpage=webread(T.makeUrl('board.xml'),T.Options);
                n=boardpage(strfind(boardpage,'<b7>')+4:strfind(boardpage,'</b7>')-1);
                % the retrieved name is 15 char long, right padded with spaces
                n=strtrim(n);
                T.LastError='';
            catch
                T.reportError('reading name of switch %s failed, offline?',T.Id);
                n=[];
            end
        end

        function b=get.Sensors(T)
            try
                resp = webread(T.makeUrl('st0.xml'),T.Options);
                ai=nan(1,9);
                for i=1:numel(ai)
                    k1=strfind(resp,sprintf('<ia%d>',i-1))+5;
                    k2=strfind(resp,sprintf('</ia%d>',i-1))-1;
                    ai(i)=str2double(resp(k1:k2));
                end
                b.BoardTemperature=ai(1)/10;
                % factor /10 guessed here, we'll see with real sensors
                %  Apparently, -600 is what the webby displays as N/A 
                b.TemperatureSensors=ai(2:7)/10;
                b.VoltageSensor=ai(8)/100;
                b.Vsupply=ai(9)/10;
                T.LastError='';

            catch
                T.reportError('reading name of switch %s failed, offline?',T.Id);
                b=[];
            end
        end

    end
    
    methods(Description='api,must-be-connected')
        connect(T)
    end


end