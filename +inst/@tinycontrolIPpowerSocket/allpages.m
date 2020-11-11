function xmlpages=allpages(T)
% retrieve all xml pages from the IP power socket. To decide what to do
%  with them if ever
    pages={'st0.xml','st2.xml','s.xml','w.xml','sch.xml','board.xml','s_time.xml'};
    xmlpages=cell(1,length(pages));
    for i=1:length(pages)
        xmlpages{i}=webread(T.makeUrl(pages{i}),T.Options);
    end
end