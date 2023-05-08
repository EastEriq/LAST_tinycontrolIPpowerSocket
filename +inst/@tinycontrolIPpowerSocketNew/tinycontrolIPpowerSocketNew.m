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
        User='admin'; % username for connecting, usually 'admin'
        Password='admin' % password for the controlling user (should match what flashed in the device)
    end

    properties (Hidden,SetAccess=private)
        HttpClient; % the obs.api.HttpClient object responsible for transport
        MAC % mac address of the device
        Name % name of the device, as flashed from the webby config
    end

    properties (Hidden, Constant)
        Timeout=5; % timeout for webreads, in seconds
    end

    methods
        % creator
        function T=tinycontrolIPpowerSocketNew(Locator)
            % Now REQUIRES locator. Think at implications
            if exist('Locator','var') 
                if isa(Locator,'obs.api.Locator')
                    id = Locator.Canonical;
                else
                    id=Locator;
                end
            else
                id='';
            end
            T.Id=id;
            % load configuration (including Host, [user, [password]])
            T.loadConfig(T.configFileName('create'))
            % fill initial status of untyped .Connected
            T.Connected=false;
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

        function set.Connected(T,tf)
            % when called via the API, the argument is received as a string
            if isa(tf,'string')
                tf=eval(tf);
            end
            if isempty(T.Connected)
                T.Connected=false;
            end
            % don't try to connect if already connected, as per API wiki
            if ~T.Connected && tf
                T.Connected=T.connect;
            elseif T.Connected && ~tf
                T.Connected=~T.disconnect;
            end
        end

        % getters and setters

        function o=get.Outputs(T)
            o=false(1,6);
            if T.Connected
                try
                    resp = T.HttpClient.GET('PAGE','st0.xml');
                    for i=1:6
                        o(i)= resp.(sprintf('out%d',i-1))==1;
                    end
                    T.LastError='';
                catch
                    T.reportError('reading status of switch %s failed, offline?',T.Id);
                    o=[];
                    T.Connected=false;
                end
            end
        end

        function set.Outputs(T,outputs)
            if T.Connected
                try
                    currentOutputs=T.Outputs;
                    for i=1:min(numel(outputs),6)
                        if outputs(i) ~= currentOutputs(i)
                            T.HttpClient.GET('PAGE',...
                                sprintf('outs.cgi?out%d=%d',i-1,outputs(i)));
                        end
                    end
                    T.LastError='';
                catch
                    T.reportError('setting status of switch %s failed, offline?',T.Id);
                    T.Connected=false;
                end
            end
        end
        
        function m=get.MAC(T)
            m=[];
            if T.Connected
                try
                    m=T.HttpClient.GET('PAGE','board.xml').b6;
                    T.LastError='';
                catch
                    T.reportError('reading MAC of switch %s failed, offline?',T.Id);
                    T.Connected=false;
                end
            end
        end

        function n=get.Name(T)
            n='';
            if T.Connected
                try
                    % the retrieved name is 15 char long, right padded with spaces
                    n=strtrim(T.HttpClient.GET('PAGE','board.xml').b7);
                    T.LastError='';
                catch
                    T.reportError('reading name of switch %s failed, offline?',T.Id);
                    T.Connected=false;
                end
            end
        end

        function b=get.Sensors(T)
            b=[];
            if T.Connected
                try
                    resp = T.HttpClient.GET('PAGE','st0.xml');
                    ai=nan(1,6);
                    for i=1:numel(ai)
                        % data is apparently T/10, and -600 is what the webby displays as N/A
                        b.TemperatureSensors(i)=resp.(sprintf('ia%d',i))/10;
                    end
                    b.TemperatureSensors(b.TemperatureSensors==-60)=NaN;
                    b.BoardTemperature=resp.ia0/10;
                    b.VoltageSensor=resp.ia7/100;
                    b.Vsupply=resp.ia8/10;
                    T.LastError='';
                catch
                    T.reportError('reading name of switch %s failed, offline?',T.Id);
                    T.Connected=false;
                end
            end
        end

    end


end