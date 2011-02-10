% Simple script to extract info from stimpres list xls...

clc;clear all;close all;

%% config
stimpresListXLS = ['sempr/sempr_sc/lists/stimlist011805.xls'];
[numerics, text, raw ] = xlsread(stimpresListXLS);
%first line of text is header, erase it
text = text(2:end,:);


%% three lists by numerics(:,3)
for jj=1:3
    listInd = find(numerics(:,3) == jj );
    cond4 = find(numerics(:,2) == 4);
    cond5 = find(numerics(:,2) == 5);
    lengthh = length(listInd)+length(cond4)+length(cond5);
    newData = cell(lengthh,5);
    for ii = 1:length(listInd)
        newData(ii,1) = text(listInd(ii),4);
        newData(ii,2) = text(listInd(ii),6);
        newData{ii,3} = numerics(listInd(ii),2);
        newData{ii,4} = numerics(listInd(ii),1);
        newData{ii,5} = 0;
    end
    kk = 1;
    cond4Items = (1:length(cond4)) + 400;
    for ii = length(listInd)+1:length(cond4)+length(listInd)
        newData(ii,1) = text(cond4(kk),4);
        newData(ii,2) = text(cond4(kk),6);
        newData{ii,3} = numerics(cond4(kk),2);
        newData{ii,4} = cond4Items(kk);
        newData{ii,5} = 0;
        kk = kk + 1;
    end
    kk = 1;
    cond5Items = (1:length(cond5)) + 500;
    for ii = length(listInd)+length(cond4)+1:length(cond4)+length(listInd)+length(cond5)
        newData(ii,1) = text(cond5(kk),4);
        newData(ii,2) = text(cond5(kk),6);
        newData{ii,3} = numerics(cond5(kk),2);
        newData{ii,4} = cond5Items(kk);
        newData{ii,5} = 0;
        kk = kk + 1;
    end
    
    % upper all
    newData(:,1) = upper(newData(:,1));
    newData(:,2) = upper(newData(:,2));
    
    % find longest prime
    a = cellfun(@length, newData(:,1));
    fprintf('Longest prime from this set is %d characters.\n',max(a));
    
    % write out
    stimuliFilename = ['stimuli/MaskedMM_' num2str(jj) '_1.stimuli'];
    fid = fopen(stimuliFilename,'w');
    for ii = 1:length(newData)
        fprintf(fid,'%s\t%s\t%i\t%i\t%i\n',newData{ii,:});
    end
    fclose(fid);
end