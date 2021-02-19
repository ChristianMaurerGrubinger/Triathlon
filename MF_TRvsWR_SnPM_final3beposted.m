% Difference between warm and transition run
% written by Christian Maurer-Grubinger final version 31.01.2021
% 
% TriathlonData is a repository of joint angles from 16 different runners.
% Joint anlges are calculated from inertial sensors in a software provided
% by the vendor of the devices (xsense) 
% 
% segmentation of the running cyclce in individual step cycles was
% performed in matlab based on the position data of the foot (heel and toe)
% with a treshohld of 2 cm above the local minimum. Every step was time
% normalized to 100 points. !! Not the full stride, but the individual
% steps were considered, as these are the smallest unique unit (left and 
% right can be mirrored to match each other).
% 
% Main array of joint angles is the variable:
% All_vectors_of_int consisting of 16 subjects x 2 conditions (1st warm,
% 2nd transition) x 2 sides (1st right 2nd left, trunk angles of the left 
% side are mirrored to match the direction of the right side angles).
% Every cell contains 10 steps x 3000 angle - dimension - timepoints. 
% Only the used 10 angles are provided to reduce file size. Joints were
% used in the order: L5S1, L4L3, L1T12, T9T8, active hip, active knee,
% active ankle, passive hip, passive knee, passive ankle. Names are storred
% in the variable: 
% 
% Settings.JointNamesMirrod(UsedJoints)
% 
% the dimensions are abduction, rotation, flexion. This is storred in: 
% 
% Settings.Dimensionsjoint
% 
% the vector of angle - dimension - timepoint is organized as following: 
% 1st angle of 1st dimension of 1st time point
% 1st angle of 1st dimension of 2nd time point
% ...
% 1st angle of 1st dimension of 100th time point
% 1st angle of 2nd dimension of 1st time point
% ...
% 1st angle of 2nd dimension of 100th time point
% 1st angle of 3rd dimension of 1st time point
% ...
% 1st angle of 3rd dimension of 100th time point
% 2nd angle of 1st dimension of 1st time point
% ...
% 
% 
% Variables depending on position data were calculated prior to this
% script. The calculation for these are not included in this script, but
% the values are directly transfered. Especially these variables are:
% step length
% velocity
% frequency
% relative stance phase
% if you need further insight to the calculation pleas contact:
% christian.maurer.cm@gmail.com


load('TriathlonData.mat')
% MF_Read_data
% to run the script you need 

s = what('spm1d');
if ~isempty(s)
if strcmp(s.path(end-5:end),'+spm1d')


    %% Calculate median vectors 
clear Median_vectors
Median_vectors = {}; % median vector was used throught because of the small 
% sample size.
for ind_sub = 1:16
   for ind_side = 1:2
    for ind_cond = 1:2 
        for ind_joint = 1:size(UsedJoints,2)
            for ind_dim = 1:3
                Median_vectors(ind_sub,ind_cond,ind_side) = {median(All_vectors_of_int{ind_sub,ind_cond,ind_side}(:,:,:))};%...
            end
        end
    end
   end
end

%% Velocity, Frequency, Stride Length
sub_count = 1;
clear MeanVel STDVel MeanFrequency MeanStrideLength
for ind_sub = 1:16 
    for ind_cond = 1:2
        switch ind_cond
            case 1
                Cond_name = 'Iso Warm';
            case 2
                Cond_name = 'Transition'; 
        end
        clear Quest
        Quest.SubjectID = ['SID' num2str(ind_sub,'%02.0f')];
        Quest.Condition1 = Cond_name;
        Quest1 = struct2table(Quest);
        ind_trial = find(ismember(ConditionTable(:,{'SubjectID','Condition1'}),Quest1));
        if size(Mean_velolity{ind_sub,ind_cond,1},1) ~= 0
MeanVel(sub_count,ind_cond) = Mean_velolity{ind_sub,ind_cond,1}(1); 
STDVel(sub_count,ind_cond) = std([velolity_of_int{ind_sub,ind_cond,1}(:,1);velolity_of_int{ind_sub,ind_cond,1}(:,1)]);
MeanFrequency(sub_count,ind_cond) = Mean_velolity{ind_sub,ind_cond,1}(1)/...
    Mean_step_length{ind_sub,ind_cond,1}(1)/3.6*60;
MeanStrideLength(sub_count,ind_cond) = Mean_step_length{ind_sub,ind_cond,1}(1);
        end

    end
sub_count = sub_count +1;
end
disp(['Mean Velocity: ' num2str(mean(MeanVel))])
disp(['STD Velocity: ' num2str(mean(STDVel))])
disp(['Mean Frequency: ' num2str(mean(MeanFrequency))])
disp(['Mean Step Length: ' num2str(mean(MeanStrideLength))])

relToe_off = 60.4; %the relative stance phase was calculated based on position
% data. Not included in this data set.

%% Median Data Calculation
clear Interval_1 Interval_2 Interval_1r Interval_2r Interval_1l Interval_2l
Screen = get(0,'ScreenSize');
Count = 1;
for ind_sub = 1:16 
%     if size(Median_vectors{ind_sub,3,1}) >= 2 
        Interval_1r(Count,:) = Median_vectors{ind_sub,2,1}(1,:);
        Interval_1l(Count,:) = Median_vectors{ind_sub,2,2}(1,:);
        Interval_2r(Count,:) = Median_vectors{ind_sub,1,1}(1,:);
        Interval_2l(Count,:) = Median_vectors{ind_sub,1,2}(1,:);
        Count = Count +1;
%     end
end
Interval_1 = [Interval_1r;Interval_1l];
Interval_2 = [Interval_2r;Interval_2l];

 
%% Test for Distribution
clear h
for ind = 1:3000
    h(ind) = kstest(Interval_1(:,ind));
end
mean(h)


%% TTest (nonparametric) WR and TR for each Joint

alpha      = 0.05;
two_tailed = true;
for ind_joint = 1:10
    for ind_dim = 1:3
        
        Frames = 300*(ind_joint-1)+100*(ind_dim-1)+(1:100);
        iterations = 1000;
        Transitioneffect       = spm1d.stats.nonparam.ttest_paired(Interval_1(:,Frames),Interval_2(:,Frames));
        Transitioneffecti      = Transitioneffect.inference(alpha, 'two_tailed', two_tailed, 'iterations', iterations);
        disp(Transitioneffecti)
        figure
        Transitioneffecti.plot();
        Transitioneffecti.plot_threshold_label();
        Transitioneffecti.plot_p_values();
        ylim([-3 5]);
        Transitioneffecti.plot();
        Transitioneffecti.plot_threshold_label();
        Transitioneffecti.plot_p_values();  
        title([Settings.JointNamesMirrod{UsedJoints(ind_joint)} '-' ...
            Settings.Dimensionsjoint{ind_dim}])
    end
end


%% Differences per Athlete

for ind_sub = 1:16
    Warm(ind_sub,:) = ...
        median([All_vectors_of_int{ind_sub,1,1}(:,:);All_vectors_of_int{ind_sub,1,2}(:,:)]);
    Transition(ind_sub,:) = ...
        median([All_vectors_of_int{ind_sub,2,1}(:,:);All_vectors_of_int{ind_sub,2,2}(:,:)]);
end
Diff_TW = Transition - Warm;
%% Test for Distribution
clear h
for ind = 1:3000
    h(ind) = kstest(Warm);
    i(ind) = kstest(Transition);
end
disp(mean(h))
disp(mean(i))


%% TR minus WR differences combined

%Test for Distribution
clear h
for ind = 1:3000
    h(ind) = kstest(Diff_TW(:,ind));
end
mean(h) 

medianDiffT1W1 = median(Diff_TW);

medianTransitionAll = median(Transition);

medianWarmAll = median(Warm);

Perz25DiffT1W1 = prctile(Diff_TW,25);
Perz75DiffT1W1 = prctile(Diff_TW,75);

Perz25Warm = prctile(Warm,25);
Perz75Warm = prctile(Warm,75);
Perz25Transition = prctile(Transition,25);
Perz75Transition = prctile(Transition,75);


%% Plot medians of TR and WR in Used Joints

for ind_joint = 1:10
    for ind_dim = 1:3
        if ishandle(10*(ind_dim-1)+ind_joint)
            close(10*(ind_dim-1)+ind_joint)
        end
        figure(10*(ind_dim-1)+ind_joint)
        Frames = 300*(ind_joint-1)+100*(ind_dim-1)+(1:100);
        plot(medianWarmAll(Frames),'Color',[0.8,0.2,0.1],'linewidth',2)
        hold on
        plot(medianTransitionAll(Frames),'Color',[0.1,0.3,0.8],'linewidth',2)
        plot(Perz25Warm(Frames),'Color',[0.8,0.2,0.1])
        plot(Perz75Warm(Frames),'Color',[0.8,0.2,0.1])
        plot(Perz25Transition(Frames),'Color',[0.1,0.3,0.8])
        plot(Perz75Transition(Frames),'Color',[0.1,0.3,0.8])
        limity = get(gca,'ylim');
        plot([60.4 60.4],limity,'k','linewidth',2)
        plot([56.4 56.4],limity,'k')
        plot([64.4 64.4],limity,'k')
        hold off
        title('Median and IQR', 'fontsize',12)
        ylabel('Joint Angles (Degree °)','fontsize',12)
        xlabel('Percentage of the Step Cycle','fontsize',12)
    end
end


%% Plot differences of TR and WR in used joints

for ind_joint = 1:10
    for ind_dim = 1:3
        if ishandle(10*(ind_dim-1)+ind_joint)
            close(10*(ind_dim-1)+ind_joint)
        end
        figure(10*(ind_dim-1)+ind_joint)
        Frames = 300*(ind_joint-1)+100*(ind_dim-1)+(1:100);
        plot(medianDiffT1W1(Frames),'k','linewidth',2)
        hold on
        plot(Perz25DiffT1W1(Frames),'Color',[0.5 0.5 0.5])
        plot(Perz75DiffT1W1(Frames),'Color',[0.5 0.5 0.5])
%         ylim([-0.8,0.6]);
        limity = get(gca,'ylim');
        plot([60.4 60.4],limity,'k','linewidth',2)
        plot([56.4 56.4],limity,'k')
        plot([64.4 64.4],limity,'k')
        hold off
        title('Median Difference and IQR', 'fontsize',12)
        ylabel('Joint Angles (Degree °)','fontsize',12)
        xlabel('Percentage of the Step Cycle','fontsize',12)

    end
end
else
    msgbox([{'To run the script you need the spm toolbox from Pataky'};...
        {'Please download the files from: https://spm1d.org/'}])
end
else
    msgbox([{'To run the script you need the spm toolbox from Pataky'};...
        {'Please download the files from: https://spm1d.org/'}])
end
