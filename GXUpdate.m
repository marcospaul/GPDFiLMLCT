function GP_opt_plus=GXUpdate(GX_opt,X_opt,y_opt,x_test,y_test,npoints_originalmodality,npoints_added)

NoiseFn_update = GP_ClampNoise(GP_MultiNoise([npoints_originalmodality npoints_added]),[1:2], [4e-1 7e-2]);  
X_update=[X_opt,x_test];
y_update=[y_opt,y_test];
GP_opt_plus = Solve_NoisyGP(X_update,y_update,NoiseFn_update);
