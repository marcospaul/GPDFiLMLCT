
function Rplus=update_cholesky(R,K)
% Updating the Cholesky factor L with only one point already in K
% Parameters: 
% R: The cholesky factor size n*n
% K: The updated Covariance Matrix size n+1*n+1

%npoints typically is one,unless you want to add points by batch
i=length(R);
%z = K(:,i+1); % Updated covariance matrix
z = K(i+1,:); % Updated covariance matrix
z=z';
% Now update R using z as the i+1 column (and row) of A
%ud = R'\z(1:i);
ud = R\z(1:i); % probably change this to R'
%i=length(ud);
ud(i+1) = sqrt(z(i+1) - ud'*ud);
a =[R,zeros(i,1)];
b = [a;(ud)'];
Rplus = real(b);
