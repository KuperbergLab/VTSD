

clc;clear all;close all;
KbName('UnifyKeyNames');


fontName = 'Helvetica';
fontInfo = FontInfo('Fonts');
fontStruct = fontInfo(find(strcmp({fontInfo(:).name},fontName)));
fontAsc = fontStruct.metrics.verticalMetrics.ascent;
fontDes = fontStruct.metrics.verticalMetrics.descent;
amtToGrow = abs(max([fontAsc fontDes])) ;


              gap = .2;
screenNumber=max(Screen('Screens'));
wPtr = Screen('OpenWindow',screenNumber,0,[],32,2);
Screen('TextFont',wPtr, fontName);

ascSize = 20;

KbQueueCreate;
KbQueueStart;

while 1
%     Screen('TextSize',wPtr,ascSize);
%     DrawFormattedText(wPtr,'y','center','center', WhiteIndex(wPtr));
%     bl = Screen('Flip',wPtr);
%     
%     Screen('TextSize',wPtr, nrmSize);
%     DrawFormattedText(wPtr,'#','center','center',WhiteIndex(wPtr));
%     bl = Screen('Flip',wPtr,bl + gap);
%     
%     Screen('Flip',wPtr, bl + gap);
%     [wp fp] = KbStrokeWait;
%     
%     if wp && strcmp(KbName(fp>0),'ESCAPE')
%         break;
%     end
%     KbQueueFlush;

    Screen('TextSize',wPtr,ascSize);
    DrawFormattedText(wPtr,MakeRandomString(1,10,'upper'),'center','center',WhiteIndex(wPtr));
    crap = Screen('Flip',wPtr);       
    [s kc ds] = KbStrokeWait;
    if strcmp(KbName(find(kc)),'ESCAPE')
        break;
    end
end

sca