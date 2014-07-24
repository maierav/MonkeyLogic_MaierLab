%t_rndnoise
%timing file for displaying random noise stimuli

% set editable vars
editable('fix_radius','fix_acquire','fix_duration','punish_duration','reward_schedule_type','n_juice');

% fixation window (in degrees):
fix_radius = 0.5;


% define time intervals (in ms):
fix_delay = 500; %wait 500 ms before aquiring fixation
fix_acquire = 1000 ;
fix_duration = 500;
obj_duration = 100;
punish_duration = 3000;
n_juice = 5;

% control optional task features
reward_schedule_type = 3; % 0 = constant, 1 = random, 2 = pyramid

% give names to the TaskObjects defined in the conditions file:
fix_screen = 1;
obj_1 = 2;
obj_2 = 3; 
obj_3 = 4;
obj_4 = 5;
obj_5 = 6;
obj_6 = 7;
obj_7  = 8;
obj_8  = 9;
obj_9  = 10;
obj_10 = 11;
nobj   = 11;
objvec = fliplr(2:obj_10); 

% get the computer time for the trial start
TrialRecord.Tstart(TrialRecord.CurrentTrialNumber) = toc(uint64(1));

% initial fixation:
toggleobject(fix_screen,'status','on'); 

ontarget = eyejoytrack('acquirefix', fix_screen, fix_radius, fix_acquire);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(fix_screen,'status','off')
    return
end

ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, fix_duration);

if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([fix_screen],'status','off')
    idle(punish_duration) % punishment delay
    return
end

toggleobject(fix_screen,'status','off'); 

%display TaskObjects (noise stimuli)
for odis = 2:nobj-1
    
    if odis == 2
    toggleobject([objvec fix_screen],'status','on');
    end
    ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, obj_duration);
    
    if ~ontarget,
        trialerror(3); % broke fixation
        toggleobject([odis fix_screen],'status','off')
        idle(punish_duration) % punishment delay
        return
    end
   
    toggleobject(odis,'status','off')

    fprintf('error on it %d?\n',odis);
end

% everything off
toggleobject([objvec fix_screen],'status','off')
trialerror(0); % correct

% get the computer time for the trial end
TrialRecord.Tend(TrialRecord.CurrentTrialNumber) = toc(uint64(1));

% give reward
% juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
% user_text(sprintf('juice pumps = %u',juice))
% goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);

% % calculate and save ITI to table
% if(TrialRecord.CurrentTrialNumber > 1)
%     ITIeff = TrialRecord.Tstart(TrialRecord.CurrentTrialNumber) - TrialRecord.Tend(TrialRecord.CurrentTrialNumber-1);
% else
%     ITIeff = NaN;
% end
% % record ITI to table
% tblnm = fullfile(pwd, 'iti.dat');
% if(exist(tblnm,'file') ~= 2)  % create the table file
%     tblptr = fopen(tblnm, 'w');
%     fprintf(tblptr,'Tstart  Tend  ITIeff  TrialNo  BlockNo  CondNo\n');
% else
%     tblptr = fopen(tblnm, 'a');
% end
% fprintf(tblptr,' %.4f  %.4f  %.4f  %6d  %6d   %6d\n',...
%     TrialRecord.Tstart(TrialRecord.CurrentTrialNumber), ...
%     TrialRecord.Tend(TrialRecord.CurrentTrialNumber), ...
%     ITIeff, ...
%     TrialRecord.CurrentTrialNumber,  ...
%     TrialRecord.CurrentBlock, ...
%     TrialRecord.CurrentCondition);
% fclose(tblptr);