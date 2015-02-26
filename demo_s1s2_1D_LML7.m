%% Matlab Script
% The variation on this method is that in this method the order of testing
% points is not important. 
% This Script Load 3 different Signals S1 and S2 and, which were taken by randomly
% sampled x(t) and adding noise with different levels.
% S3 in constrast sampled half of a modified signal x'(t) (e.g. a virtual wall) 
% and half of x(t). 
% Like LML2 but random and with the option of CholeskyUpdate

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
experiment=5; % Set manually the number of the experiment, you can check
% Note.txt for a description of the experiment 
% Set variables to 1 to activate that option or to zero to desactivate.
display=1;% To display Graphics
save_files=1; % Save Files in a specific path
make_movie=1;

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
npoints_added=1;
npoints_originalmodality=k;
p=1;
X_consistent=[];
y_consistent=[];
X_inconsistent=[];
y_inconsistent=[];
tested_index=0;
tc=0;
flag_modelup=1;

%for(p=1:k)
%   GP_opt_plus=GXUpdate(GP_opt,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added);% Note:Npoints added including the new one 
%   lml_test(p)=GP_opt_plus.lml;
%end
passes=1;
for (p=1:k)
    
    %GP_opt_plus=GXUpdate(GP_opt,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added);% Note:Npoints added including the new one
    GP_test=copy_model(GP_opt);
    GP_opt_plus=GXUpdate_L(GP_test,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added);% Note:Npoints added including the new one 
    %Lets visualise the updated model
    [mf_updated, vf_updated] = GP_opt_plus.query(xstar2);
    sf_updated  = sqrt(vf_updated);

    if(display)
       idx=p;
       display_iter3; % Script to display graph
       if(save_files)
         if(p<10)% change p fpr tc
            export_fig(sprintf('./snapshots/pdf/%s/LMLFusion_Pass0%d_Iter0%d.pdf',filename,passes,p))% replace p for tc to save only matches
         else
            export_fig(sprintf('./snapshots/pdf/%s/LMLFusion_Pass0%d_Iter%d.pdf',filename,passes,p))% replace for tc
         end
        savefig(sprintf('./snapshots/fig/%s/LMLFusion_Pass0%d_Iter%d.fig',filename,passes,p))% replace for tc
       end
    end
    

    if(LMLTEST(GP_opt,GP_opt_plus)>0)
        npoints_added=npoints_added+1;
        sprintf('updating model ... %d',tc)
        GP_opt=GP_opt_plus; % model updated
        X_opt=[X_opt,X_test(p)]; % Update X
        y_opt=[y_opt,y_test(p)]; % Update y
        X_consistent=union(X_consistent,X_test(p),'stable');
        y_consistent= union(y_consistent,y_test(p),'stable');
        tc=tc+1;
        tested_index(tc)=p;
    else
        X_inconsistent=union(X_inconsistent,X_test(p),'stable');
        y_inconsistent=union(y_inconsistent,y_test(p),'stable');
    end
    %close all
end

%if(make_movie)
 %   cd ./snapshots/pdf/
  %  % Convert pdftoImages in Ubuntu
 %   !for i in *.pdf; do convert "$i" "${i%.*}.png"; done
%end

new_points=1;
while(new_points)
    close all
    new_points=0;
    passes=passes+1;
    pass=0;
    for (p=1:k)

        already_tested=find(p==tested_index);
        if(isempty(already_tested))


            %GP_opt_plus=GXUpdate(GP_opt,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added);% Note:Npoints added including the new one
             GP_test=copy_model(GP_opt);
            GP_opt_plus=GXUpdate_L(GP_test,X_opt,y_opt,X_test(p),y_test(p),npoints_originalmodality,npoints_added);% Note:Npoints added including the new one 
            %Lets visualise the updated model
            [mf_updated, vf_updated] = GP_opt_plus.query(xstar2);
            sf_updated  = sqrt(vf_updated);

            if(display)
               idx=p;
               display_iter3; % Script to display graph
               if(save_files)
                 if(p<10)% change p fpr tc
                    export_fig(sprintf('./snapshots/pdf/%s/LMLFusion_Pass0%d_Iter0%d.pdf',filename,passes,p))%replace for tc to save only matches
                 else
                    export_fig(sprintf('./snapshots/pdf/%s/LMLFusion_Pass0%d_Iter%d.pdf',filename,passes,p))% replace p for tc
                 end
                savefig(sprintf('./snapshots/fig/%s/LMLFusion_Pass0%d_Iter%d.fig',filename,passes,p))% replace p fpr tc
               end
            end


            if(LMLTEST(GP_opt,GP_opt_plus)>0)
                npoints_added=npoints_added+1;
                sprintf('updating model ... %d',tc)
                GP_opt=GP_opt_plus; % model updated
                X_opt=[X_opt,X_test(p)]; % Update X
                y_opt=[y_opt,y_test(p)]; % Update y
                X_consistent=union(X_consistent,X_test(p),'stable');
                y_consistent= union(y_consistent,y_test(p),'stable');
                tc=tc+1;
                tested_index(tc)=p;
                new_points=1;
                
            else
                X_inconsistent=union(X_inconsistent,X_test(p),'stable');
                y_inconsistent=union(y_inconsistent,y_test(p),'stable');
           
            end
            %close all
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
cd ..
cd ..
cd ..
close all
end

    

