function ex = MakeExStruct(exname,subjectname,scanner,list,run)

% don't change this unless you know what you're doing
if isstr(list)
    gFmtStr = '%s%s%s%s%d%f%d';
else
    gFmtStr = '%s%s%s%d%d%f%d';
end

ex.projPath = '~/Documents/MATLAB/';
ex.name = exname;
ex.subjectName = subjectname;
ex.scanner = scanner;
ex.list = list;
ex.run = run;
ex.logFmtStrG = gFmtStr;



if (strcmp(ex.scanner,'MEG') && strcmp(ex.name,'AX-CPT'))
    ex.stimulusFilename = [ ex.projPath 'stims/' ex.name '/psychTB/' num2str(ex.list) '_Run' num2str(ex.run) '_MEG'];
else
    ex.stimulusFilename = [ ex.projPath 'stims/' ex.name '/psychTB/' num2str(ex.list) '_Run' num2str(ex.run)];
end

mkdir([ex.projPath 'vtsd_logs/' ex.scanner],ex.subjectName)
ex.logFilename = [ex.projPath 'vtsd_logs/' ex.scanner '/' ex.subjectName '/' ex.name '_' ex.subjectName  ...
    '_List' num2str(ex.list) '_Run' num2str(ex.run) '.vtsd_log'];