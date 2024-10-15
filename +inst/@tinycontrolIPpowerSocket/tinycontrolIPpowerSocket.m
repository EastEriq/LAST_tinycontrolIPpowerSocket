classdef tinycontrolIPpowerSocket < obs.LAST_Handle
    % interfacing with the power socket using matlab's native
    %  webread/webwrite. I have the slight suspect that they are based on
    %  obscure callbacks, because we experience occasional "offline?"
    %  answers when there is messenger traffic, even with Timeout=4sec.
    
    properties
        Outputs=false(1,6);  % power at each socket, false=OFF/true=ON
    end
    
    properties (Hidden)
        Host='192.168.1.100'; % ip or hostname
        User='admin'; % username for connecting, usually 'admin'
        Password='admin' % password for the controlling user (should match what flashed in the device)
    end
    
    % these properties are hidden because it takes time to retrieve them:
    properties (Hidden,SetAccess=private)
        Sensors % 1-wire sensors and board temperature
        MAC % mac address of the device
        Name % name of the device, as flashed from the webby config
        Options % weboptions() for web queries to the device, e.g. User, Password, Timeout
        % Add a timer object for querying the switch with
        %  noninterruptible callbacks
        QueryHttpPage  char;
        HttpReply char;
        HttpCollector  timer;
    end
    
    properties (Hidden)
        Timeout=4; % timeout for webreads, in seconds
    end
    
    methods
        % creator
        function T=tinycontrolIPpowerSocket(id)
            T.GitVersion=obs.util.tools.getgitversion(mfilename('fullpath'));
            if exist('id','var')
                T.Id=id;
            end
            % load configuration (including Host, [user, [password]])
            T.loadConfig(T.configFileName('create'))
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',T.Timeout);
             % set the callback function here, instead of creating anew the
            %  timer. I have no good solution for deleting the timer when 
            %  clearing the object, so I try to delete it if it is
            %  already in the workspace. It is important to delete, rather
            %  than to recycle, because the timer associated to a destroyed
            %  object will reference an invalid serial resource
            delete(timerfind('Name',['PswitchInquirer_',T.Id]));
            T.HttpCollector=timer('Name',['PswitchInquirer_',T.Id],...
                        'ExecutionMode','SingleShot','BusyMode','Queue',...
                        'StartDelay',0,'TimerFcn',@(~,~)T.queryCallback);
       end
        
        % destructor, allowing for a shutdown status
        function delete(T)
            % Better not. For some reason an old object may be
            %  deleted after a new one is created, causing the
            %  shutdown config to be enforced just after the same
            %  device is turned on
            % T.loadConfig(T.configFileName('destroy'))
        end
        
        % getters and setters
        function set.User(T,user)
            T.User=user;
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',T.Timeout);
        end

        function set.Password(T,password)
            T.Password=password;
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',T.Timeout);
        end
        
        function set.Timeout(T,timeout)
            T.Timeout=timeout;
            T.Options=weboptions('Username',T.User,'Password',T.Password,...
                'Timeout',T.Timeout);
        end

        function o=get.Outputs(T)
            try
                resp = T.webquery('st0.xml');
                o=false(1,6);
                for i=1:6
                    o(i)=(resp(strfind(resp,sprintf('<out%d>',i-1))+6)=='1');
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
                boardpage=T.webquery('board.xml');
                m=boardpage(strfind(boardpage,'<b6>')+4:strfind(boardpage,'</b6>')-1);
                T.LastError='';
            catch
                T.reportError('reading MAC of switch %s failed, offline?',T.Id);
                m=[];
            end
        end

        function n=get.Name(T)
            try
                boardpage=T.webquery('board.xml');
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
                resp = T.webquery('st0.xml');
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
                T.reportError('reading sensor page of switch %s failed, offline?',T.Id);
                b=[];
            end
        end

    end

end