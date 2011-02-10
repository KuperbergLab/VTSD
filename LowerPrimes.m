clc;clear all;close all;



for list = [101 201 301]
    for run = 1:2
%         filename = ['/Volumes/kuperberg/SemPrMM/stims/MaskedMM/psychTB/' num2str(list) '_Run' num2str(run)];
        filename = ['~/Documents/MATLAB/stims/MaskedMM/psychTB/' num2str(list) '_Run' num2str(run)];
        fid = fopen(filename,'r');
        data = textscan(fid,'%s%s%d%d%d');
        fclose(fid);
        
        newData = cell(length(data{1}),5);
        newData(:,1) = lower(data{1});
        newData(:,2) = data{2};
        newData(:,3) = num2cell(data{3});
        newData(:,4) = num2cell(data{4});
        newData(:,5) = num2cell(data{5});
        
        fid = fopen(filename,'w');
        for ii = 1:length(newData)
            fprintf(fid,'%s\t%s\t%d\t%d\t%d\n',newData{ii,:});
        end
        fclose(fid);
    end
end