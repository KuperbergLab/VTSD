subject = 'ya31';
ATLLocList = 201;
MaskedMMList = 201;
BaleenList = 204;
AXCPTList = 101;

VTSD('ATLLoc',subject,'MRI',ATLLocList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('MaskedMM',subject,'MRI',MaskedMMList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('MaskedMM',subject,'MRI',MaskedMMList,2);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,2);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,3);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,4);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,5);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,6);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,7);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('BaleenMM',subject,'MRI',BaleenList,8);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('AXCPT',subject,'MRI',AXCPTList,1);
fprintf('\nPress any key to continue to the next experiment...');
KbStrokeWait;

VTSD('AXCPT',subject,'MRI',AXCPTList,2);
fprintf('\nYou have finished, thanks for participating...');

