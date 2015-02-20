%% Matlab Script
% This Script Load 3 different Signals S1 and S2 and, which were taken by randomly
% sampled x(t) and adding noise with different levels.
% S3 in constrast sampled half of a modified signal x'(t) (e.g. a virtual wall) 
% and half of x(t). 

%Note: Rebuilding entire model. 

%% Add libraries
% Library to export pdf
addpath(genpath('~/Desktop/matlab_visualization_scripts'));
% MI library
addpath(genpath('/home/marcos/Programming/ML/Information_Theory/MI'));
% Library to compute noisy GPs
addpath(genpath('/home/marcos/Programming/ML/TacoPig_withTortilla'));
% Place matlab in the working directory
cd /home/marcos/Programming/OutlierRejection/GBP/
clear all; close all; clc 


%% *** Data Visualization Libraries *** %%
load('./Dataset/Inconsistent_Signals');
load ./Dataset/Consistent_Signals
load ./Dataset/Consistent_Signals% Load x(t), s1 and s2


% Display Signals (s1,s2 and x(t))
display_1;%script
%export_fig('./Pictures/Samples_s1s2.pdf')

%% Load Inconsistent Signals: s3 and y3 (basically is just that one, for now) 
%load('./Dataset/Inconsistent_Signals');
% Display s3
display_2;

%export_fig('./Pictures/Samples_s3s2.pdf')

%% Performing Regression (GP-noisy-inputs)

% for s2
X2= [t(s2)]';
y2= [y2]';
n2 = size(X2,2);
xstar2 = linspace(0, 0.02, length(X2)); % and query on a grid


NoiseFn2 = GP_ClampNoise(GP_MultiNoise([60]),[1], [4e-1]);    
GP1 = Solve_NoisyGP(X2,y2,NoiseFn2);
[mf2, vf2] = GP1.query(xstar2);
sf2  = sqrt(vf2);

display_3;
%export_fig('./Pictures/Learnt_s1.pdf')

% for s3
X3= [t(s3)]';
y3= [y3]';
n3 = size(X3,2);
xstar3 = linspace(0, 0.02, length(X3)); % and query on a grid
NoiseFn3 = GP_ClampNoise(GP_MultiNoise([60]),[1], [7e-2]);  
GP2 = Solve_NoisyGP(X3,y3,NoiseFn3);
display_4;

%h(4) = scatter(t(s2(1:10)), y2(1:10), 'k','filled');
%xlabel('time (in seconds)');
%export_fig('./Pictures/Learnt_s2_smoke.pdf'); 

%% Iterative LML-CT
% we have GP1 for radar : Initialization of variables
X_opt=X2;
y_opt=y2;
GP_opt=GP1;


X_test=X3;
y_test=y3;
k=length(X3);

% Parameters
npoints_added=1;
npoints_originalmodality=60;
p=1;
c_update=0;
X_consistent=0;
y_consistent=0;
X_inconsistent=0;
y_inconsistent=0;


for (p=1:k)
    %GP_opt_plus=GXUpdate(GX_opt,X_test(p),y_test(p));
    GP_opt_plus=GXUpdate(GP_opt,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added)% Note:Npoints added including the new one
    %Lets visualise the updated model
    [mf_updated, vf_updated] = GP_opt_plus.query(xstar2);
    sf_updated  = sqrt(vf_updated);

    display_iter; % Script to display graph
    

    if(LMLTEST(GP_opt,GP_opt_plus)>0)
        npoints_added=npoints_added+1;
        sprintf('updating model ... %d',c_update)
        GP_opt=GP_opt_plus; % model updated
        X_opt=[X_opt,X_test(p)]; % Update X
        y_opt=[y_opt,y_test(p)]; % Update y

        X_consistent=union(X_consistent,X_test(p),'legacy');
        y_consistent= union(y_consistent,y_test(p),'legacy');
    else
        X_inconsistent=union(X_inconsistent,X_test(p),'legacy');
        y_inconsistent=union(y_inconsistent,y_test(p),'legacy');
    end
end


