function VTSD(exname,subjectname,scanner,list,run)
% VTSD(exname,subjectname,scanner,list,run,location)

% Visual Text Stimulus Driver
% Scott Burns
% Kuperberg Lab
% Documentation can be found at
% https://gate.nmr.mgh.harvard.edu/wiki/kuperberg-lab/index.php/VTSD

%% Section 0
warning('off','MATLAB:dispatcher:InexactCaseMatch');
clc;
keyboards = GetKeyboardIndices();
if length(keyboards) == 1
    compKeyboardInd = keyboards(1);
    scannerKeyboardInd = keyboards(1);
else
    compKeyboardInd = keyboards(1);
    scannerKeyboardInd = keyboards(2);
end

switch nargin
    case 0
        exname = 'BaleenMM';
        subjectname = 'test';
        scanner = 'MRI';
        list = 101;
        run = 1;
    case 1
        subjectname = 'test';
        scanner = 'MRI';
        list = 101;
        run = 1;
    case 2
        scanner = 'MRI';
        list = 101;
        run = 1;
    case 3
        list = 101;
        run = 1;
    case 4
        run = 1;
end


% not debug but in fmri?
if nargin == 5 && ~strcmp(subjectname,'test') && strcmp(scanner,'MEG')
    DCOMM = true;
else
    DCOMM = false;
end

%% Section 1 - Globals



% Keynames
detectButton1 = KbName('6^');
detectButton2 = KbName('7&');
detectButton3 = KbName('8*');
detectButton4 = KbName('9(');
TriggerButton = KbName('=+');
EscapeButton = KbName('ESCAPE');
SpaceBar = KbName('SPACE');
FontToUse = 'Helvetica';

% MEG Trigger
MEGTriggerBegin = 13;
MEGTriggerPrime = 14;

% VTSD Constants
textSize = 20;
crossSize = 48;

%% Section 2 - Experiment Parameters

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



if (strcmp(ex.scanner,'MEG') && strcmp(ex.name,'AXCPT'))
    ex.stimulusFilename = [ ex.projPath 'stims/' ex.name '/psychTB/' num2str(ex.list) ...
        '_Run' num2str(ex.run)];% '_MEG'];
else
    ex.stimulusFilename = [ ex.projPath 'stims/' ex.name '/psychTB/' num2str(ex.list) ...
        '_Run' num2str(ex.run)];
end

ex.logdir = fullfile(ex.projPath,'vtsd_logs',ex.scanner,ex.subjectName);

if ~exist(ex.logdir,'dir')
    mkdir(ex.logdir);
end
ex.logFilename = [ex.projPath 'vtsd_logs/' ex.scanner '/' ex.subjectName '/' ex.name ...
    '_' ex.subjectName '_List' num2str(ex.list) '_Run' num2str(ex.run) '.vtsd_log'];


fprintf('Study Name\t------>\t%s\n',ex.name);
fprintf('Subject Name\t------>\t%s\t\n',ex.subjectName);
fprintf('Scanner Type\t------>\t%s\n',ex.scanner);
if isstr(ex.list)
    fmt = 'Stimuli List\t------>\t%s\n';
else
    fmt = 'Stimuli List\t------>\t%d\n';
end
fprintf(fmt,ex.list);
fprintf('Subject Run\t------>\t%d\n',ex.run);
fprintf('\n\n');

% Make sure these parameters are right!
response = [];
while (~(strcmp(response,'y') || strcmp(response,'n')))
    response = input('Are these parameters correct (y/n)?:','s');
end
if strcmp(response,'n')
    fprintf('\nNot continuing...goodbye.\n');
    return
end

%% Section 3 - Init communication with scanner
if DCOMM
    di = DaqDeviceIndex;
    DaqDConfigPort(di,0,0);
    DaqDOut(di,0,0);
end

%% Section 4 - Load Parameters, Stimuli, Log Files

[ex.params ex.stimFmtStr] = ReadExperimentParameters(ex);
ex.stimulusMatrix = ReadStimulusFile(ex);
[indexToBegin ex.logFilename]= CheckLogFile(ex);

fprintf('\n\nWriting to the log file at:\n');
fprintf('%s\n',ex.logFilename);

ex.totalITI = 0;
ex.paramsCumSum = cumsum(ex.params(1:end-1))/1000;
ex.trialTime = sum(ex.params(1:end-1))/1000;

fprintf('\n\nExperimenter: waiting for trigger from machine...\n');
WaitSecs(.2);
[keyDown, secs, keyCode] = KbCheck(-1);
while ~keyDown
    [keyDown, secs, keyCode] = KbCheck(-1);
end

if keyCode(EscapeButton)
    fprintf('Goodbye')
    return;
end
    
%% Section 5 - Experiment dependent processing


switch ex.name
    case {'MaskedMM', 'MaskedMM_SC'}
        maskText = '#########'; %for now
        maskSize = floor(1.65*textSize);
        instText = 'Press a button\nwhen you see\nan insect.';
    case 'BaleenMM'
        instText = 'Press a button\nwhen you see\nan animal.';
    case {'ATLLoc','ATLLoc_SC'}
        instText = 'Read the words silently\nas they appear.';
    case {'AXCPT','AXCPT_SC'}
        instText = 'Press a button\nwhen an\nX follows an A.';
    case 'Blink'
        instText = 'Blink when you see --- + ---.';
    otherwise
        instText = [];
        
end


% account for delays in the projector
switch ex.scanner
    case {'MRI','MEG'}
        frameDelay = 2;
    case 'assessment'
        frameDelay = 0;
    otherwise
        frameDelay = 0;
end

vbls = zeros(length(ex.stimulusMatrix),length(ex.paramsCumSum)+1);

%% Section 6 - Start Psychtoolbox

% If there's any call to Screen that is unclear, type Screen [function]? at
% the command line. For instance, to read about Screen('Flip'), type Screen
% Flip?.
try
    %PTB Init
    old = PTBInit();
    
    % Route all keyboard input to script, not matlab cmd window
    ListenChar(2);

    % Use the 2nd display (the main display (w/ menubar) on OS X is always 0);
    screenNumber=max(Screen('Screens'));
    wPtr = Screen('OpenWindow',screenNumber,0,[],32,2);
    
    % Take a measure of IFI at high OS priority
    Priority(9);
    ifi = Screen('GetFlipInterval',wPtr);
    Priority(0);
    
    % Compute the delay factor (which takes into account projector delay
    % and half-ifi time.
    switch ex.scanner
        case {'MRI','MEG'}
            frameDelay = 2;
        case 'assessment'
            frameDelay = 0;
        otherwise
            frameDelay = 0;
    end
    delayFactor = .5*ifi + frameDelay * ifi;
    
    % Start experiment
    % Welcome screen
    Screen('TextFont',wPtr, 'Helvetica');
    vbl = Screen('Flip',wPtr);
    

    % Instruction Text
    Screen('TextSize',wPtr,textSize);
    DrawFormattedText(wPtr,instText,'center','center',WhiteIndex(wPtr));
    Screen('DrawingFinished',wPtr);
    Screen('Flip',wPtr,vbl + 3 - delayFactor);
    
    % Start the keyboard queue (on the specific keyboard indice, not the
    % 'merged' state (doesn't seem to work in MRI scanner).
    KbQueueCreate(scannerKeyboardInd);
    
    % But, for whatever reason, KbCheck(-1) works (-1 denoting the 'merged
    % state').  
    [a,b,keyCode] = KbCheck(-1);
    % wait for trigger from keyboard or MRI
    while ~keyCode(TriggerButton)
        [a,b,keyCode] = KbCheck(-1);
    end
    
    Priority(9);

    % Grab a time baseline for the entire experiment
    KbQueueStart();
    baseTime = GetSecs();
    if DCOMM
        if strcmp(ex.scanner,'MEG')
            TriggerMEG(di,MEGTriggerBegin);
        end
    end
    
    %%%%%%%%%%%%%
    % Main Loop %
    %%%%%%%%%%%%%
    
    for currentStim = indexToBegin:length(ex.stimulusMatrix)
        
        % Compute the baseline time this trial starts at, in a perfect world
        perfectTrialBase = (currentStim-1)*ex.trialTime+ex.totalITI+baseTime;
        
        % Compute the times at which stimuli should present, in a perfect world
        perfectRequests = ex.paramsCumSum + perfectTrialBase;

        % Run the experiment-dependent trial
        switch ex.name
            case 'SpanDC'
                Screen('TextSize',wPtr,textSize);
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,1},'center','center',WhiteIndex(wPtr));
                timeToLog = Screen('Flip',wPtr);
                [s kc ds ] = KbStrokeWait(keyboardInd);
                if (ex.stimulusMatrix{currentStim, 2} == 3)
                    keyStr = KbName(find(kc));
                    keyStr = keyStr(1);
                    reactionTime = str2double(keyStr);
                else 
                    reactionTime = 0;
                end
                if strcmp(KbName(find(kc)),'ESCAPE')
                    throw(MException('VTSD:UserTermination','User terminated the experiment.'));
                end
                iti = 0;
            
            case 'Blink'
                %---Cross is on Screen from beginning
                
                % blank
                Screen('Flip',wPtr);
                Screen('TextSize',wPtr,textSize);
                DrawFormattedText(wPtr,'--- + ---','center','center',WhiteIndex(wPtr));
                timeToLog = Screen('Flip',wPtr,perfectRequests(1)-delayFactor);
                if DCOMM
                    TriggerMEG(di,1);
                end
                
                iti = 0;
                
                Screen('Flip',wPtr,perfectRequests(2)-delayFactor);
            
            case {'AXCPT','AXCPT_SC'}
               
                %---Cross is on screen from beginning
                
                % A/not-A
                Screen('TextSize',wPtr,textSize);
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,1},'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                timeToLog = Screen('Flip',wPtr);
                switch ex.stimulusMatrix{currentStim,1}
                    case 'A'
                        triggerCode = 5;
                    otherwise
                        triggerCode = 6;
                end
                %SB added 20101206
                if length(ex.stimulusMatrix{currentStim,1}) > 1
                    triggerCode = 7;
                end
                if DCOMM
                    TriggerMEG(di,triggerCode);
                end
                %---A/not-A is on screen
                
                % blank after a/not-a
                Screen('Flip',wPtr,perfectRequests(1)-delayFactor);
                %---Screen is blank
                
                % x/notx 
                Screen('TextSize',wPtr,textSize);%
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,2},'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                Screen('Flip',wPtr,perfectRequests(2)-delayFactor);
                if DCOMM
                    TriggerMEG(di,ex.stimulusMatrix{currentStim,3});%
                end
                % Screen is x/notx
                
                % blank after x/notx
                Screen('Flip',wPtr,perfectRequests(3)-delayFactor);
                % Screen is blank
                
                
                Screen('Flip',wPtr,perfectRequests(4)-delayFactor);
                
                if strcmp(ex.scanner, 'MRI')
                    iti = ex.stimulusMatrix{currentStim,5}/1000;
                else
                    iti = ex.params(end)/1000;
                end
                ex.totalITI = ex.totalITI + iti;
                timeAtEnd = Screen('Flip',wPtr,perfectRequests(4)+iti-delayFactor);
                
                % Time to blink
                if strcmp(ex.scanner, 'MEG') && mod(currentStim,2) == 0
                    Screen('TextSize',wPtr,crossSize);
                    DrawFormattedText(wPtr,'--- + ---','center','center',WhiteIndex(wPtr));
                    timeAfterRest = Screen('Flip',wPtr);
                    %make sure the numbers in the next two lines add up to
                    %third line
                    blankTime = Screen('Flip',wPtr,.8+timeAfterRest);
                    timeAfterBlank = Screen('Flip',wPtr,.2+blankTime);
                    ex.totalITI = ex.totalITI + 1;
                end
                
            case {'ATLLoc','ATLLoc_SC'}
                begTrial = GetSecs();
                %---Cross is on screen, from beginning or previous trial
                
                % blank  after Cross
                time = Screen('Flip',wPtr,perfectRequests(1)-delayFactor);
                vbls(currentStim,1) = time-begTrial;
                if DCOMM
                    TriggerMEG(di,ex.stimulusMatrix{currentStim, 10});
                end
                %---Screen is blank
                
                
                Screen('TextSize',wPtr,textSize);%textSize
                for currentWord = 1:9 %
                    DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,currentWord},'center','center',WhiteIndex(wPtr));
                    Screen('DrawingFinished',wPtr);
                    % Current word after blank
                    vbl(currentWord) = Screen('Flip',wPtr,perfectRequests(currentWord*2)-delayFactor);
                    vbls(currentStim, currentWord*2) = vbl(currentWord)-begTrial;
                    if DCOMM
                        TriggerMEG(di,4);%
                    end
                    %---Screen is current word
                    time = Screen('Flip',wPtr,perfectRequests(currentWord*2+1)-delayFactor);
                    vbls(currentStim,currentWord*2+1) = time - begTrial;
                    %---Screen is blank
                end
                timeToLog = vbl(1);
                % Draw Cross, flip based on scanner
                Screen('TextSize',wPtr,crossSize);
                DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                if strcmp(ex.scanner,'MRI')
                    iti = ex.stimulusMatrix{currentStim,12}/1000;
                else
                    iti = ex.params(21)/1000;
                end
                ex.totalITI = ex.totalITI + iti;
                time = Screen('Flip',wPtr,perfectRequests(6)+iti-delayFactor);
                
                % Time to blink
                if strcmp(ex.scanner, 'MEG')
                    DrawFormattedText(wPtr,'--- + ---','center','center',WhiteIndex(wPtr));
                    timeAfterRest = Screen('Flip',wPtr);
                    %make sure the numbers in the next two lines add up to
                    %third line
                    blankTime = Screen('Flip',wPtr,.8+timeAfterRest);
                    DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                    timeAfterBlank = Screen('Flip',wPtr,.2+blankTime);
                    ex.totalITI = ex.totalITI + 1;
                end
                
            case {'MaskedMM', 'MaskedMM_SC'}
                begTrial = GetSecs();
                
                %---Screen is cross, from beginning or previous
                % blank  after Cross
                time = Screen('Flip',wPtr,perfectRequests(1)-delayFactor);
                vbls(currentStim,1) = time - begTrial;
                %---Screen is blank
                
                % FMask after blank
                Screen('TextSize',wPtr,maskSize);
                DrawFormattedText(wPtr,maskText,'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                time = Screen('Flip',wPtr,perfectRequests(2)-delayFactor);
                vbls(currentStim,2) = time-begTrial;
                %---Screen is FMask
                
                % Prime after Fmask
                Screen('TextSize',wPtr,textSize);
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,1},...
                    'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                time = Screen('Flip',wPtr,perfectRequests(3)-delayFactor);
                vbls(currentStim,3) = time - begTrial;
                %---Screen is prime
                if DCOMM
                    TriggerMEG(di,MEGTriggerPrime);
                end
                
                % BMask after Prime
                Screen('TextSize',wPtr,maskSize);
                DrawFormattedText(wPtr,maskText,'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                time = Screen('Flip',wPtr,perfectRequests(4)-delayFactor);
                vbls(currentStim, 4) = time-begTrial;
                %---Screen is BMask
                
                % Target after BMask
                Screen('TextSize',wPtr,textSize);%
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,2},...
                    'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                timeToLog = Screen('Flip',wPtr,perfectRequests(5)-delayFactor);
                vbls(currentStim,5) = timeToLog-begTrial;
                %---Screen is Target
                if DCOMM
                    TriggerMEG(di,ex.stimulusMatrix{currentStim,3});%
                end
                
                % blank after target
                time = Screen('Flip',wPtr,perfectRequests(6)-delayFactor);
                vbls(currentStim,6) = time-begTrial;
                %---Screen is blank
                
                % cross after blank
                Screen('TextSize',wPtr,crossSize);
                DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                time = Screen('Flip',wPtr,perfectRequests(7)-delayFactor);
                vbls(currentStim,7) = time-begTrial;
                %---Screen is cross
                
                % draw cross, but flip based on scanner
                if strcmp(ex.scanner,'MRI')
                    iti = ex.stimulusMatrix{currentStim,5}/1000;
                else
                    iti = ex.params(8)/1000;
                end
                %make sure cross stays up
                ex.totalITI = ex.totalITI + iti;
                Screen('TextSize',wPtr,crossSize);
                DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);                
                time = Screen('Flip',wPtr,perfectRequests(7)+iti-delayFactor);
                vbls(currentStim,8) = time-begTrial;

                % Time to blink
                if strcmp(ex.scanner, 'MEG') && mod(currentStim,2) == 0
                    DrawFormattedText(wPtr,'--- + ---','center','center',WhiteIndex(wPtr));
                    timeAfterRest = Screen('Flip',wPtr);
                    %make sure the numbers in the next two lines add up to
                    %third line
                    blankTime = Screen('Flip',wPtr,.8+timeAfterRest);
                    DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                    timeAfterBlank = Screen('Flip',wPtr,.2+blankTime);
                    ex.totalITI = ex.totalITI + 1;
                end
                
            case 'BaleenMM'
                begTrial = GetSecs();
                %---Cross is on screen, from beginning or previous trial
                
                
                % blank  after Cross
                time = Screen('Flip',wPtr,perfectRequests(1)-delayFactor);
                vbls(currentStim,1) = time-begTrial;
                %---Screen is blank
                
                
                % prime
                Screen('TextSize',wPtr,textSize);
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,1},'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                time = Screen('Flip',wPtr,perfectRequests(2)-delayFactor);
                vbls(currentStim,2) = time-begTrial;
                %---Screen is prime
                if DCOMM
                    TriggerMEG(di,MEGTriggerPrime);
                end
                
                
                % blank
                time = Screen('Flip',wPtr,perfectRequests(3)-delayFactor);
                vbls(currentStim,3) = time-begTrial;
                %---Screen is blank
                
                % target
                Screen('TextSize',wPtr,textSize);%
                DrawFormattedText(wPtr,ex.stimulusMatrix{currentStim,2},'center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                timeToLog= Screen('Flip',wPtr,perfectRequests(4)-delayFactor);
                vbls(currentStim,4) = timeToLog-begTrial;
                %---Screen is target                
                if DCOMM
                    TriggerMEG(di,ex.stimulusMatrix{currentStim,3});%
                end
                
                % blank
                time = Screen('Flip',wPtr,perfectRequests(5)-delayFactor);
                vbls(currentStim,5) = time-begTrial;
                %----Screen is blank
                
                % cross
                Screen('TextSize',wPtr,crossSize);
                DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                time = Screen('Flip',wPtr,perfectRequests(6)-delayFactor);
                vbls(currentStim,6) = time-begTrial;
                %---Screen is cross

                
                % draw cross, but flip it based on scanner iti
                DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                Screen('DrawingFinished',wPtr);
                if strcmp(ex.scanner,'MRI')
                    iti = ex.stimulusMatrix{currentStim,5}/1000;
                else
                    iti = ex.params(end)/1000;
                end
                ex.totalITI = ex.totalITI + iti;
                time = Screen('Flip',wPtr,perfectRequests(6)+iti-delayFactor);
                vbls(currentStim,7) = time-begTrial;
                
                % Time to blink
                if strcmp(ex.scanner, 'MEG') && mod(currentStim,2) == 0
                    DrawFormattedText(wPtr,'--- + ---','center','center',WhiteIndex(wPtr));
                    timeAfterRest = Screen('Flip',wPtr);
                    %make sure the numbers in the next two lines add up to
                    %third line
                    blankTime = Screen('Flip',wPtr,1.2+timeAfterRest);
                    DrawFormattedText(wPtr,'+','center','center',WhiteIndex(wPtr));
                    timeAfterBlank = Screen('Flip',wPtr,.2+blankTime);
                    ex.totalITI = ex.totalITI + 1.4;
                end
                
            otherwise
                error('Experiment is not implemented in main loop.')
        end
        
        % Get any key presses 
        [wasPressed fp fr lp lr] = KbQueueCheck();
        detectionKeys = [detectButton1 detectButton2 detectButton3 detectButton4];
        detectionTimes = [fp(detectButton1) fp(detectButton2) ...
            fp(detectButton3) fp(detectButton4)];
        if wasPressed && any(detectionTimes)
            reactionTime = fp(detectionKeys(find(detectionTimes > 0,1))) - baseTime;
        else
            reactionTime = 0;
        end
        
        % Make timeToLog the actual time the subject saw stimuli
        timeToLog = timeToLog + frameDelay * ifi;
        
        % Log this trial
        WriteLogFile(ex,timeToLog-baseTime,currentStim,iti,reactionTime);
        
        % In emergencies, check is ESC key is held. If so, break the
        % experiment.  
        [a, b, keyCode] = KbCheck(compKeyboardInd);
        if keyCode(EscapeButton)
            throw(MException('VTSD:UserTermination','User terminated the experiment.'));
        end
        
        % Removes key events
        KbQueueFlush();
    end % main loop
    displayText = 'Please rest and remain still';
    Screen('TextSize',wPtr,crossSize);
    DrawFormattedText(wPtr,displayText,'center','center',whiteIndex(wPtr));
    Screen('Flip',wPtr);
    % wait for operator (i.e. when fieldmap finishes)
    [a,b,keyCode] = KbCheck(compKeyboardInd);
    while ~keyCode(SpaceBar)
        [a,b,keyCode] = KbCheck(compKeyboardInd);
    end
catch ME
    fprintf('\n\n')
    disp(getReport(ME));
    PTBCleanup(old);
end

%% Section 7 - clean up

% If we got here, experiment proceeded successfully.  Dealloc PTB and check
% log file for tasks results.
PTBCleanup(old);
AssessLogFile(ex)
save([ex.logdir '/vbls_' ex.name '_' ex.subjectName ...
    '_List' num2str(ex.list) '_Run' num2str(ex.run) '.mat'],'vbls');
% if strcmp('MaskedMM',ex.name)
%     fprintf('\n\nI missed %d frames in this session.',...
%         length(find(vbls(:,5)-vbls(:,4) > .04)));
%     figure;hist(vbls(:,5)-vbls(:,4))
% end
return;


%%%%%%%%%%%%%%%%%%%%
% Helper Functions %
%%%%%%%%%%%%%%%%%%%%


% ReadExperimentParameters reads KuperbergExperimentParameters.txt and
% pulls three things.  The first is the timing parameters for
% the experiment. 2nd, the format string that ReadStimulusFile uses to read
% the appropriate stimulus file.  Third, the specific format string that
% both Read- and WriteLogFile use to read the associated log file.
function [experiment stimFmtStr] = ReadExperimentParameters(ex)
experimentParamsFilename = 'KuperbergExperimentParameters.txt';
fid = fopen(experimentParamsFilename,'rt');

if (-1 == fid)
    error('Could not open experiment parameters file.')
end
experiment = [];
stopReadingLine = 0;
textLine = fgetl(fid);
while (-1 ~= textLine )
    [token remaining] = strtok(textLine);
    if (strcmpi(token, ex.name))
        % We've found the right line in the text file
        [token remaining] = strtok(remaining);
        stimFmtStr = token;
        ii = 1;
        % start building experiment var
        while (~stopReadingLine)
            [token remaining] = strtok(remaining);
            if (~strcmpi(token, ';'))
                experiment(ii) = str2double(token);
                ii = ii + 1;
            else
                stopReadingLine = 1;
            end
        end
    end
    textLine = fgetl(fid);
end
if isempty(experiment);
    fprintf('Warning: experiment not found in experiment parameters file.\n');
    experiment = [];
    stimFmtStr = [];
end
fclose(fid);
return;


% ReadLogFile searches for an existing log file.  If present, it
% determines the next stimuli to begin at.  Theoretically, it'd be nice if
% this function let you start in a stimulus file the last place you left
% off, but that just isn't possible with the way I measure timing.  Maybe
% there's a fix somewhere down the road.
function [indexToBegin newLogfile] = CheckLogFile(ex)
newLogfile = ex.logFilename;
indexToBegin = 1;
% try to open logfile
fid = fopen(ex.logFilename,'r');
% if fopen returns -1, no file, nothing to parse
if ~strcmp(ex.name,'SpanDC')
    if (-1 == fid )
    else %log file exists
        fprintf('Log file to this experiment exists at:\n');
        fprintf('%s\n',ex.logFilename);
        response = '';
        while ~(strcmp(response,'a') || strcmp(response,'o') || strcmp(response,'n'))
            response = input('Do you want to (o) overwrite, (a) append, or (n) create a new log file?   ', 's');
        end
        switch response
            case 'o'
                fclose(fid);fid=fopen(ex.logFilename,'w');fclose(fid); %this wipes the existing logfile
                indexToBegin = 1;
            case 'a'
                logData = cell(1,1);
                textLine = fgetl(fid);
                ii = 1;
                while (-1 ~= textLine)
                    logData{ii} = textLine;
                    ii = ii + 1;
                    textLine = fgetl(fid);
                end
                fclose(fid);
                lastTrial = logData{end};
                stringMat = textscan(lastTrial,[ex.logFmtStrG ex.stimFmtStr '%f' ]);
                indexToBegin = stringMat{7} + 1;
            case 'n'
                fclose(fid);
                newLogfile = strrep(ex.logFilename,'.','_1.');
            otherwise
                error('Some big error in ReadLogFile');
        end
    end
% else
%     fprintf('Not scanning SpanDC log files, always overwriting...\n\n');
% % %     fclose(fid);fopen(ex.logFilename,'w');fclose(fid);%wipe
end
return;


% ReadStimulusFile reads the appropriate stimulus file and creates
% ex.stimulusMatrix, using ex.stimFtmStr.
function stimulusMatrix = ReadStimulusFile(ex)
fprintf('Reading stimulus file at:\n');
fprintf('%s\n',ex.stimulusFilename);
stimulusMatrix = [];
fid = fopen(ex.stimulusFilename);
textLine = fgetl(fid);
ii = 1;
if ~strcmp(ex.name, 'SpanDC')
    while (-1 ~= textLine)
        C = textscan(textLine,ex.stimFmtStr);
        sFmtMat = SplitFmtStr(ex.stimFmtStr);
        for jj = 1:length(sFmtMat)
            switch sFmtMat(jj,:)
                case '%s'
                    stimulusMatrix{ii,jj} = char(C{jj});
                case '%n'
                    stimulusMatrix{ii,jj} = C{jj};
            end
        end
        ii = ii + 1;
        textLine = fgetl(fid);
    end
    fclose(fid);
% else %SpanDC is weird...
%     textData = [];
%     while (-1 ~= textLine)
%         jj = 1;
%         [token remaining] = strtok(textLine);
%         while 1
%             textData{ii,jj} = token;
%             jj = jj + 1;
%             [token remaining] = strtok(remaining);
%             if isempty(token)
%                 break;
%             end
%         end
%         
%         ii = ii + 1;
%         textLine = fgetl(fid);
%     end
%     fclose(fid);
%     
%     stimulusMatrix = cell(length(textData),2);
%     
%     for ii = 1:length(textData)
%         lastInd = size(textData,2);
%         while 1
%             if isempty(textData{ii,lastInd})
%                 lastInd = lastInd - 1;
%             else
%                 break;
%             end
%         end
%         fullStr = [];
%         for jj = 1:lastInd - 1
%             fullStr = [fullStr ' ' textData{ii,jj}];
%         end
%         fullStr = strtrim(fullStr);
%         stimulusMatrix{ii,1} = fullStr;
%         stimulusMatrix{ii,2} = str2double(textData{ii,lastInd});
%     end
end
return;


% PTBCleanup should be called to exit PTB and restore normal function to
% MATLAB.  
function PTBCleanup(old)
Priority(0);
ListenChar(0);
KbQueueRelease();
Screen('CloseAll');
Screen('Preference', 'VisualDebugLevel', old.VisualDebugLevel);
Screen('Preference', 'Verbosity', old.Verbosity);
return;


% PTBInit contains code that should be called before any calls to PTB are
% made.
function old = PTBInit()
old.VisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 2);
old.Verbosity = Screen('Preference', 'Verbosity', 2);
KbName('UnifyKeyNames');


% WriteLogFile uses both ex.logFmtStrG (as in general) and ex.stimFmtStr
% (as in specific) to write out the logfile.
function WriteLogFile(ex,timee,stim,iti,rt)
fid = fopen(ex.logFilename,'a+');
if fid == -1
    error('Can not write to log file.')
end
% write out the general info
if isstr(ex.list)
    fmt = '%s\t%s\t%s\t%s\t%i\t%5.3f\t%i\t';
else 
    fmt = '%s\t%s\t%s\t%i\t%i\t%5.3f\t%i\t';
end
fprintf(fid,fmt,ex.name,ex.scanner,ex.subjectName,ex.list,ex.run,timee,stim);
% now split ex.logFmtStrS and print through a loop of the split str
sFmtMat = SplitFmtStr(ex.stimFmtStr);
for ii = 1:length(sFmtMat)
    if strcmp('%s',sFmtMat(ii,:))
        fprintf(fid,'%s\t',ex.stimulusMatrix{stim,ii});
    else
        if ( (strcmp(ex.scanner,'MEG') ...
                || ~strcmp(ex.scanner,'assessment')) ...
                && ii == length(sFmtMat))
            fprintf(fid,'%5.3f\t',iti);
        else
            fprintf(fid,'%i\t',ex.stimulusMatrix{stim,ii});
        end
    end
end
% print rt
fprintf(fid,'%5.3f\n',rt);
fclose(fid);
return;


% Reshapes an array like '%s%s%s%n' to 
% %s
% %s
% %s
% %n which can more easily be used as a looping variable.
function fmtMat = SplitFmtStr(strToSplit)
fmtMat = [];
lToSplit = length(strToSplit);
fmtMat = reshape(strToSplit,2,lToSplit/2)';
return;


% AssessLogFile reads the logfile from a finished experiment and prints out
% things of interest like success rate, miss rate, successful rejections,
% and wrongful rejections (false positives)
function AssessLogFile(ex)
fid = fopen(ex.logFilename,'r');
if fid ~= -1
    C = textscan(fid, [ex.logFmtStrG ex.stimFmtStr '%f']);
    fclose(fid);
else
    fprintf('\nAssessLogFile: Could not open log file.\n');
    return;
end
% ex.name ex.scanner ex.subjectname ex.list ex.run targetTime stim prime
% target code index rt
taskCode = [];
noTaskCode = [];
switch ex.name
    case 'BaleenMM'
        taskCode = [5 10 11 12];
        noTaskCode = [1 2 4 6 7 8 9];
    case {'MaskedMM', 'MaskedMM_SC'}
        % only want to look at target, maybe subject can't see
        % prime
        taskCode = [5];
        noTaskCode = [1 2 3 4];
    case {'ATLLoc','ATLLoc_SC'}
        % no task
    case {'AXCPT','AXCPT_SC'}
        taskCode = 4;
        noTaskCode = [1 2 3];
    otherwise
        fprintf(['\n'  ex.name ' not implemented in AssessLogFile\n\n']);
        return;
end
fprintf('AssessLogFile statistics...\n\n')
if (~isempty(taskCode) && ~isempty(noTaskCode))
    % # of successes
    taskInd = C{7}(arrayfun(@(x) any(x == taskCode),C{10}));
    sucTasks = find(C{13}(taskInd) > 0);
    fprintf('Success rate: %2.2f%% (%d out of %d)\n', ...
        length(sucTasks)/length(taskInd)*100,length(sucTasks),length(taskInd));
    
%     % # of misses
%     failTasks = find(C{13}(taskInd) == 0);
%     fprintf('Miss rate: %2.2f%% (%d out of %d)\n', ...
%         length(failTasks)/length(taskInd)*100,length(failTasks),length(taskInd));

    % # of successful rejections
    noTaskInd = C{7}(arrayfun(@(x) any(x == noTaskCode),C{10}));
    sucNoTask = find(C{13}(noTaskInd) == 0);
    fprintf('Successful rejection rate: %2.2f%% (%d out of %d)\n', ...
        length(sucNoTask)/length(noTaskInd)*100,length(sucNoTask),length(noTaskInd));
    
%     % # of missed rejections
%     failNoTask = find(C{13}(noTaskInd) > 0);
%     fprintf('Missed rejection rate: %2.2f%% (%d out of %d)\n', ...
%         length(failNoTask)/length(noTaskInd)*100,length(failNoTask),length(noTaskInd));
    
else
    fprintf('\n\nNo task in this experiment\n\n');
end


% little wrapper function
function TriggerMEG(di,code)
DaqDOut(di,0,code);
DaqDOut(di,0,0);
return;
