%% Matlab Script
% The variation on this method is that in this method the order of testing
% points is not important. 
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
%cd /home/marcos/Programming/OutlierRejection/GBP/
%cd /home/marcos/Programming/OutlierRejection/GPIS_INSAC
cd ~/Programming/git_repo/GPDFiLMLCT/
clear all; close all; clc 


%% Control Variables
experiment=6; % Set manually the number of the experiment, you can check
% Note.txt for a description of the experiment 
% Set variables to 1 to activate that option or to zero to desactivate.
display=1;% To display Graphics
save_files=0; % Save Files in a specific path
make_movie=0;

%% Testing Variables
lml_test=0;

if(save_files)
filename=sprintf('Snapshot_%s_%d',date,experiment);
mkdir(sprintf('./snapshots/fig/%s',filename))
mkdir(sprintf('./snapshots/pdf/%s',filename))
end

%% *** Data Visualization Libraries *** %%
load('./Dataset/Inconsistent_Signals');
load ./Dataset/Consistent_Signals
load ./Dataset/Consistent_Signals% Load x(t), s1 and s2

% Display Signals (s1,s2 and x(t))
if(display)
display_1;%script
end
%export_fig('./Pictures/Samples_s1s2.pdf')

%% Load Inconsistent Signals: s3 and y3 (basically is just that one, for now) 
%load('./Dataset/Inconsistent_Signals');
% Display s3
if (display)
display_2;
end

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

if(display)
display_3;
end
%export_fig('./Pictures/Learnt_s1.pdf')

% for s3
X3= [t(s3)]';
y3= [y3]';
n3 = size(X3,2);
xstar3 = linspace(0, 0.02, length(X3)); % and query on a grid
NoiseFn3 = GP_ClampNoise(GP_MultiNoise([60]),[1], [7e-2]);  
GP2 = Solve_NoisyGP(X3,y3,NoiseFn3);
if(display)
display_4;
end
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
npoints_added=0;
npoints_originalmodality=60;
p=1;
c_update=0;
X_consistent=[];
y_consistent=[];
X_inconsistent=[];
y_inconsistent=[];
tested_index=0;
tc=0;
flag_modelup=1;
indextotext=0;


while(flag_modelup)
    flag_modelup=0;
    indextotest=[];
    X_inconsistent=[];
    y_inconsistent=[];
    for(p=1:k)
      if(p~=tested_index)
       GP_opt_plus(p)=GXUpdate(GP_opt,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added+1);% Note:Npoints added including the new one 
       %sprintf('in')
         if(LMLTEST(GP_opt,GP_opt_plus(p))>0) % does it pass the test. 
           %lml_test(p)=GP_opt_plus(p).lml;
           indextotest(p)=p;
         else
           X_inconsistent=union(X_inconsistent,X_test(p),'stable'); %legacy if order, stable not ordered
           y_inconsistent=union(y_inconsistent,y_test(p),'stable');
         end   
      end
    end
    
    % now take the equivalent p index for idx
    %Select the one that passes the test. 
    idx=find(indextotest);
    %if(tc==0)
    %    npoints_added=length(idx);
    %end
    npoints_added=npoints_added+length(idx);
    GP_opt_plus=GXUpdate(GP_opt,X_opt,y_opt,X_test(idx),y_test(idx),npoints_originalmodality,npoints_added);% Note:Npoints added including the new one            
    [mf_updated, vf_updated] = GP_opt_plus.query(xstar2);
    sf_updated  = sqrt(vf_updated);
   
      
    if(LMLTEST(GP_opt,GP_opt_plus)>0)
        %npoints_added=length(idx); % WARNING: not sure if this is correct
        sprintf('updating model ... %d',c_update)
        GP_opt=GP_opt_plus; % model updated
        X_opt=[X_opt,X_test(idx)]; % Update X
        y_opt=[y_opt,y_test(idx)]; % Update y
        X_consistent=union(X_consistent,X_test(idx),'stable');
        y_consistent= union(y_consistent,y_test(idx),'stable');
        tc=tc+1;
        tested_index=union(tested_index,idx,'stable');%WARNING
        c_update=c_update+1;
        %tested_index(tc)=idx;
        flag_modelup=1;
        %npoints_added=npoints_added+1; %for the next iteration
    else
        %X_inconsistent=union(X_inconsistent,X_test(idx),'legacy');
        %y_inconsistent=union(y_inconsistent,y_test(idx),'legacy');
    end
    
     if(display)
        display_iter2; % Script to display graph
        if(save_files)
            if(tc<10)
                export_fig(sprintf('./snapshots/pdf/%s/LMLFusion_Iter0%d.pdf',filename,tc))
            else
                export_fig(sprintf('./snapshots/pdf/%s/LMLFusion_Iter%d.pdf',filename,tc))
            end
            
            savefig(sprintf('./snapshots/fig/%s/LMLFusion_Iter%d.fig',filename,tc))

        end
    end

 end
        

    
    
if(make_movie)
   cd ./snapshots/pdf/
   cd(filename)
 %  Convert pdftoImages in Ubuntu
    !mkdir ./images
    %cd ./images
    !for i in *.pdf; do convert "$i" "${i%.*}.png"; done
    %cd ..
    !mkdir ./video
    !mencoder mf://*.png -mf w=800:h=600:fps=3:type=png -ovc copy -oac copy -o ./video/output3.avi
    
    ! mv *.png ./images

end
%for i in *.png; do mencoder mf://"$i" -mf w=800:h=600:fps=3:type=png -ovc copy -oac copy -o output2.avi; done






