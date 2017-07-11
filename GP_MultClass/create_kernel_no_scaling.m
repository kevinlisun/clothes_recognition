function K = create_kernel_no_scaling(X1,X2,kernel_,T,p)

[N1 d]		= size(X1);
[N2 d]		= size(X2);

switch kernel_
case 'invsin'
  nx = size(X1,1);
  ny = size(X2,1);  
  s = (X1*T*X2'); 
  d1 = sqrt(1+sum((X1.^2)*T,2)*ones(1,ny));
  d2 = sqrt(1+ones(nx,1)*sum((X2.^2)*T,2)');
  K = asin(s./(d1.*d2));
case 'gauss',
    K	= exp(-dist(X1,X2,T));  %%%%%
case 'poly',
  K	= (1+X1*T*X2').^p;
case 'innerprod'
  K = X1*T*X2';
end
  
function distance = dist(X,Y,T)
nx	= size(X,1);
ny	= size(Y,1);

distance=sum((X.^2)*T,2)*ones(1,ny) +...
         ones(nx,1)*sum((Y.^2)*T,2)' - 2*(X*T*Y');
