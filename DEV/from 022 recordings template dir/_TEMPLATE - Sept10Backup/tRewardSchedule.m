function n_juice = tRewardSchedule(type,n_juice,TrialRecord)
% allows user to specify a reward scheme of "type" 
% with n_juice serving as min/start number of pumps
%
% dev note: add a "params" structure as last (optional) vargin
% that can have diffrent fields of parameters for the diffrent reward types. 
% also, does ML record number of juice pumps given??
%
% December 2013, MAC 
% May 7, 2014 KAD added reward # of pumps of juice pulled from binomial
% distribtuion 

% "type" can be a string or a number
if isstr(type)
    lower(type);
elseif type > 0
    % 0 = constant
    % 1 = random
    % 2 = pyramid
    % 3 = binomial (excluding 0); KAD 5/14
    % 4 = mixed (uniform between 1 and 2 for first trials, uniform with
    % increasing range for higher number of correct trials)
    stringcode = {'random','pyramid','bino', 'mixed'};
    type = stringcode{type};
end

switch type 
    case 'random'
        % give a random number of pumps (1-5)
        n_juice = randi([n_juice,n_juice*4],1);
        
    case 'pyramid'
        % make reward dependent on behavior in prior trials
        if TrialRecord.CurrentTrialNumber > 1
            if TrialRecord.TrialErrors(end) == 0 % previous trial good
                
                % find number of consecutive error-free trials (error code 0)
                noerrors = TrialRecord.TrialErrors == 0;
                if  all(noerrors)
                    n = length(noerrors);
                else
                    n = length(noerrors) - find(diff(noerrors),1,'last');
                end
                % cap at 15 extra pumps of juice %Kacie changed 
                if n > 5
                    n = 5;
                end
                
                % get n_juice for 1st error-free trial,
                % get one more pump for each additional error-free trial
                n_juice = n_juice + (n - 1);
            end
        end
        
    case 'bino'
        % give a random number pulled from normal distribution 
        n_juice = binornd(n_juice,0.3);
      
    case 'mixed'
        
        %reward with minimum number of juice pumps for all correct trials before
        %minrew_trial
        
        minrew_trial   = TrialRecord.minrew_trial;
        ncorr = length(find(TrialRecord.TrialErrors == 0));
        if ncorr < minrew_trial
            n_juice = 1;  
        elseif ncorr>=minrew_trial & ncorr <minrew_trial + 200
            n_juice = 2;
        elseif ncorr>= minrew_trial + 200 & ncorr <minrew_trial + 400
            n_juice = 3;
        elseif ncorr>=minrew_trial + 400 & ncorr <minrew_trial + 500
             n_juice = 4; 
        else ncorr > minrew_trial + 500
            n_juice = randi([3 8]); 
        end

    otherwise
        % give n_juice pumps of reward
        % n_juice = n_juice;
end