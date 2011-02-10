function CheckTriggers


% run this script in the MEG suite to check that your triggers show up in
% the acquisition software.

di = DaqDeviceIndex;
DaqDConfigPort(di,0,0);
DaqDOut(di,0,0);

fprintf('Starting triggers...\n\n');
for ii = 1:2
   for jj = 1:12
       DaqDOut(di,0,jj);
       DaqDOut(di,0,0);
       
       WaitSecs(1);
   end
   fprintf('Done with a rep...\n\n');
end

fprintf('Sent all triggers, hope it worked.\n');




