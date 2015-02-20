%% Matlab Script
% This Script Load 3 different Signals S1 and S2 and, which were taken by randomly
% sampled x(t) and adding noise with different levels.
% S3 in constrast sampled half of a modified signal x'(t) (e.g. a virtual wall) 
% and half of x(t). 

%% Add libraries
% Library to export pdf
addpath(genpath('~/Desktop/matlab_visualization_scripts'));
% MI library
addpath(genpath('/home/marcos/Programming/ML/Information_Theory/MI'));
% Library to compute noisy GPs
addpath(genpath('/home/marcos/Programming/ML/TacoPig_withTortilla'));

% Place matlab in the working directory
cd /home/marcos/Programming/OutlierRejection/GPIS_INSAC
clear all; close all; clc 


%% *** Data Visualization  *** %%
load('./Dataset/Inconsistent_Signals');
load ./Dataset/Consistent_Signals


%% Load x(t), s1 and s2
load ./Dataset/Consistent_Signals

% Display Signals (s1,s2 and x(t))
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
    hold on
plot(t,x,'k-','LineWidth',2) % Plot both signals.
scatter(t(s2),y2,'r','filled')
scatter(t(s1),y1,'g','filled')
title('Training Data','FontSize',14);
%xlabel('time (in seconds)');
legend('GT','X^1','X^2');
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
ylim(gca,[-4 3]); 
%export_fig('./Pictures/Samples_s1s2.pdf')


%% Load Inconsistent Signals: s3 and y3 (basically is just that one, for now) 
%load('./Dataset/Inconsistent_Signals');
% Display s3
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
    grid(axes,'on');
    hold on
plot(t,x,'k-','LineWidth',2) % Plot both signals.
scatter(t(s2),y2,'r','filled')
scatter(t(s3),y3,'g','filled')
title('Training Data','FontSize',14);
%xlabel('time (in seconds)');
legend('GT','X^1','X^2');
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
ylim(gca,[-4 3]); 

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

figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
hold on
f2  = [mf2+2*(sf2),flipdim(mf2-2*(sf2),2)]';
h(1) = fill([xstar2, flipdim(xstar2,2)], f2, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
h(2) = plot(xstar2,mf2,'b-');
h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
h(4) = scatter(X2(1:60), y2(1:60), 'r','filled');

legend('Standard Deviation','Mean','GT','X^1')
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
%xlabel('time (in seconds)');
ylim(gca,[-4 3]);
title('S^1','FontSize',14);
%export_fig('./Pictures/Learnt_s1.pdf')



% for s3
X3= [t(s3)]';
y3= [y3]';
n3 = size(X3,2);
xstar3 = linspace(0, 0.02, length(X3)); % and query on a grid
NoiseFn3 = GP_ClampNoise(GP_MultiNoise([60]),[1], [7e-2]);  
GP2 = Solve_NoisyGP(X3,y3,NoiseFn3);
[mf3, vf3] = GP2.query(xstar3);
sf3  = sqrt(vf3);
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
hold on
f3  = [mf3+2*(sf3),flipdim(mf3-2*(sf3),2)]';
h(1) = fill([xstar3, flipdim(xstar3,2)], f3, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
h(2) = plot(xstar3,mf3,'b-');
h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
h(4) = scatter(X3(1:60), y3(1:60), 'g','filled');
%legend(h,'Predictive Standard Deviation','Predictive Mean','GT','Training Points')
legend('Standard Deviation','Mean','GT','S^2')
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
ylim(gca,[-4 3]);
title('S^2','FontSize',14);
hold on
%h(4) = scatter(t(s2(1:10)), y2(1:10), 'k','filled');
%xlabel('time (in seconds)');
%export_fig('./Pictures/Learnt_s2_smoke.pdf'); 


%% Sorting some signals that are actually very mesy :S
[t1_sort,index]=sort(t(s1));
y1_sort=y1(index);
%t1=t()
figure;
scatter(t1_sort(1:60),y1_sort)
%Now lets take a few samples from the left side of the signal 19-27 and
%8-10-12-14-16
index_samples=[8,10,12,14,16,19:27]
scatter(t1_sort(1:60),y1_sort) %all
scatter(t1_sort(index_samples),y1_sort(index_samples),'r')

% Now modifing radar as well ... making it noisier on the right edge, a lot
% more noisy, for example avoid taking the last 10 ?
[X2_sort,index]=sort(X2);
y2_sort=y2(index)';
index_samples2=[1:50,55,60]
XX2=X2_sort(index_samples2);
yy2=y2_sort(index_samples2);


%Solving a new GP ;)
XX3= [t(s3);t1_sort(index_samples)]';
yy3= [y3';y1_sort(index_samples)]';
%plotting this
figure
scatter(XX3,yy3)

nn3 = size(XX3,2);
xxstar3 = linspace(0, 0.02, length(XX3)); % and query on a grid
NNoiseFn3 = GP_ClampNoise(GP_MultiNoise([74]),[1], [7e-2]);

GGP2 = Solve_NoisyGP(XX3,yy3,NNoiseFn3);
[mmf3, vvf3] = GGP2.query(xxstar3);
ssf3  = sqrt(vvf3);
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
hold on
ff3  = [mmf3+2*(ssf3),flipdim(mmf3-2*(ssf3),2)]';
h(1) = fill([xxstar3, flipdim(xxstar3,2)], ff3, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
h(2) = plot(xxstar3,mmf3,'b-');
h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
h(4) = scatter(XX3(1:74), yy3(1:74), 'g','filled');
%legend(h,'Predictive Standard Deviation','Predictive Mean','GT','Training Points')
legend('Standard Deviation','Mean','GT','S^2')
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
ylim(gca,[-4 3]);
title('S^2','FontSize',14);
hold on





%% Fusion ... s2 and s3 (raw data).
X_f2= [t(s3); t(s2)]';
y_f2= [y3 y2];
n_f2= size(X_f2,2);
xstar_f2 = linspace(0, 0.02, length(X_f2)); % and query on a grid
NoiseFn_f2 = GP_ClampNoise(GP_MultiNoise([60 60]),[1:2], [7e-2 4e-1]);  
GP_f2 = Solve_NoisyGP(X_f2,y_f2,NoiseFn_f2);
[mf_f2, vf_f2] = GP_f2.query(xstar_f2);
sf_f2  = sqrt(vf_f2);
% Display learnt model
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
hold on
f_f2  = [mf_f2+2*(sf_f2),flipdim(mf_f2-2*(sf_f2),2)]';
h(1) = fill([xstar_f2, flipdim(xstar_f2,2)], f_f2, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
hold on
h(2) = plot(xstar_f2,mf_f2,'b-');
h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
h(4) = scatter(X_f2(1:60), y_f2(1:60), 'g','filled');
h(5) = scatter(X_f2(61:120), y_f2(61:120), 'r','filled');
legend(h,'Standard Deviation','Mean','GT','X^2','X^1')
set(legend,...
    'Position',[0.294605715815783 0.704721840659344 0.386904761904762 0.220238095238095]);
title('Fusion','FontSize',14);
%grid(axes,'on');
%xlabel('time (in seconds)');
ylim(gca,[-4 3]);
%export_fig('./Pictures/Fusion_Catastrophic.pdf') %NB: change the size of the legends to 12



