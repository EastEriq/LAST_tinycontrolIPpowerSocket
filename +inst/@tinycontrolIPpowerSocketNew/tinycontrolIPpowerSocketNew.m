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
    end
    
    properties(Hidden, SetAccess=private,Description='api,must-be-connected')
    % these properties are hidden because it takes time to retrieve them:
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
                    id = Locator.CanonicalLocation;
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
                resp = T.HttpClient.GET('PAGE','st0.xml');
                o=false(1,6);
                for i=1:6
                    o(i)= resp.(sprintf('out%d',i-1))==1;
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
                        T.HttpClient.GET('PAGE',...
                            sprintf('outs.cgi?out%d=%d',i-1,outputs(i)));
                    end
                end
                T.LastError='';
            catch
                T.reportError('setting status of switch %s failed, offline?',T.Id);
            end
        end

        function m=get.MAC(T)
            try
                m=T.HttpClient.GET('PAGE','board.xml').b6;
                T.LastError='';
            catch
                T.reportError('reading MAC of switch %s failed, offline?',T.Id);
                m=[];
            end
        end

        function n=get.Name(T)
            try
                % the retrieved name is 15 char long, right padded with spaces
                n=strtrim(T.HttpClient.GET('PAGE','board.xml').b7);
                T.LastError='';
            catch
                T.reportError('reading name of switch %s failed, offline?',T.Id);
                n=[];
            end
        end

        function b=get.Sensors(T)
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
                b=[];
            end
        end

    end
    
    methods(Description='api,must-be-connected')
        connect(T)
    end


end