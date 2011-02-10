clc;clear all;close all;

%Little script to check .eve files

for k = 1:8
    filepath = ['/Volumes/kuperberg/SemPrMM/MEG/data/ya4/ya4_BaleenRun' num2str(k) '.eve'];
    
    fid = fopen(filepath,'r');
    if ~fid
        error('Cannot open eve file');
    end
    
    C = textscan(fid,'%f%f%f%f');
    
    fclose(fid);
    
    
    eventTimes = C{2};
    events = C{4};
    
    
    if k < 5
        taskInd = find((events == 5) | (events == 11));
    else
        taskInd = find((events == 10) | (events == 12));
    end
    rt = [];
    noResponse = 0;
    trial = [];
    numTasks = 0;
    for trial = taskInd'
        if ~(trial+1>length(events)) && (events(trial+1) == 16 || events(trial-1) == 16)
            rt = [rt eventTimes(trial+1) - eventTimes(trial)];
        else
                noResponse = noResponse + 1;
%                 fprintf('Miss: %d\n',events(trial));
        end
    end
    fprintf('Run: %d NumTasks: %d AvgRT: %3.0f(%d) NoResponse: %d\n', ...
        k,length(taskInd),1000*mean(rt),length(rt),noResponse)
end
