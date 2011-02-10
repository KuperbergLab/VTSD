clc;clear all;close all;

ListenChar(2);
KbName('UnifyKeyNames');

keyboardInd = max(GetKeyboardIndices);
trigger = KbName('=+');

% while(1)
%     [a,b,keyCode] = KbCheck(-1);
%     if keyCode(trigger)
% end


KbQueueCreate(keyboardInd);
KbQueueStart();
for i = 1:15
    
    
    % simulating the trial 
    baseTime = GetSecs();
    fprintf('trial begins...\n');
    WaitSecs(2.0);
    [p fp fr lp lr] = KbQueueCheck();
    
    if p
        for ii = find(fp)
            fprintf('you pressed the %s key at %3.3f s within the trial\n',KbName(ii),fp(ii)-baseTime);
        end 
    else
        fprintf('no keys pressed!\n');
    end
    
    
    KbQueueFlush();
    
    [a b keyCode] = KbCheck(-1);
    if keyCode('ESCAPE')
        fprintf('Escape was pressed');
        break;
    end
end
fprintf('\ngood bye again...\n');
ListenChar(0)
