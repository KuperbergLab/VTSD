subject = 'ya32';
ATLLocList = 101;
MaskedMMList = 201;
BaleenList = 104;
AXCPTList = 201;


VTSD('Blink',subject,'MEG',101,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('ATLLoc',subject,'MEG',ATLLocList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('MaskedMM',subject,'MEG',MaskedMMList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('MaskedMM',subject,'MEG',MaskedMMList,2);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,2);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,3);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,4);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,5);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,6);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,7);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MEG',BaleenList,8);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('AXCPT',subject,'MEG',AXCPTList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('AXCPT',subject,'MEG',AXCPTList,2);
fprintf('\nYou have finished, thanks for participating...');

