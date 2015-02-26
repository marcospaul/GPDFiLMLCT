%Returns an updated model by using the cholesky decomposition factor
function A=GXUpdate_L(temp,X_opt,y_opt,x_test,y_test,npoints_originalmodality,npoints_added)
NoiseFn_update = GP_ClampNoise(GP_MultiNoise([npoints_originalmodality npoints_added]),[1:2], [4e-1 7e-2]);  
temp.NoiseFn=NoiseFn_update;
% temp.NoiseFn=NoiseFn_update;
% temp.factorisation=GX.factorisation;
% temp.factors=GX.factors;
% temp.objective_function=


X_update=[X_opt,x_test];
y_update=[y_opt,y_test];

% Aspects to be updated: 
 %temp=GX_opt;
 temp.X=X_update;
 temp.y=y_update;
 %temp.X=[temp.X,x_test];
 %temp.y=[temp.y,y_test];
%
%temp.X_noise=GX.X_noise;
temp.X_noise=[temp.X_noise,zeros(1,npoints_added)]; %Noiseless?
temp.mu=temp.MeanFn.eval_y(temp.X, temp.meanpar);
%temp.NoiseFn=NoiseFn_update;

% Updating K
K = temp.CovFn.Keval(temp.X, temp.covpar);
noise = temp.NoiseFn.eval(temp, temp.noisepar);
K = K + noise;
temp.K=K;

%% Updating the Cholesky factor L
%R = chol(A(1:i, 1:i));
% Parameters: L, K_updated
temp.factors.L=update_cholesky(temp.factors.L,K);


% Updating alpha
mu = temp.MeanFn.eval_y(temp.X, temp.meanpar);
ym = (temp.y - mu)';
temp.mu=mu;
temp.alpha = temp.factors.L'\(temp.factors.L\ym);



% Updating K_noise
 predmeanX = temp.query_clean(temp.X);
    eps = 1e-9;
    predmeanX_grad = zeros(size(temp.X));

    for i = 1:size(temp.X,1)
       X_eps = temp.X;
       X_eps(i,:) = X_eps(i,:)+ eps;
       predmeanX_eps = temp.query_clean(X_eps);
       predmeanX_grad(i,:) = (predmeanX_eps-predmeanX)/eps;
    end
   %  for i = 1:length(temp.X)
   %      angles(i) = atand(predmeanX_grad(i));
   %  end
   %  xstar = linspace(-8,8,200);
   %  f_star =  this.query_clean(xstar);
%             figure; plot(this.X,predmeanX)
%             hold on; plot(xstar,f_star)
%             for i = 1:length(this.X)
%                 plot([this.X(i);this.X(i)+0.5*cosd(angles(i))],[predmeanX(i);predmeanX(i)+0.5*sind(angles(i))])
%             end 
    for i = 1:size(temp.X,2)
        X_noise_correction(i) = diag(predmeanX_grad(:,i)'*diag(temp.X_noise(:,i))*predmeanX_grad(:,i));
    end
        K_noise = K +diag(X_noise_correction);

temp.K_noise=K_noise;
temp.factors.L_noise=update_cholesky(temp.factors.L_noise,K_noise);
temp.alpha_noise = temp.factors.L_noise'\(temp.factors.L_noise\ym);


temp.lml = -GP_LMLG_FN(temp, [temp.meanpar, temp.covpar, temp.noisepar]);

A=temp;


%GP_opt
%GP_opt_plus = Solve_NoisyGP(X_update,y_update,NoiseFn_update);
