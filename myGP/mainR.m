clear
close all
clc


kernel = 2

switch kernel
    case 1
        k = @(x,y) 1*x'*y
    case 2
        gamma = 1
        k = @(x,y) exp(-gamma*sum((x-y).^2))
end
       


x = 1:1:10
x = x';
fx = rand(size(x));

y = 0.5:2:9.5
y = y';

[ Kxx ] = computeCov( x, x, k );
[ Kxy ] = computeCov( x, y, k );
[ Kyx ] = computeCov( y, x, k );
[ Kyy ] = computeCov( y, y, k );

meanf = 0;
covf = [ Kxx, Kxy; Kyx, Kyy ];

%% regression
mean = Kyx*inv(Kxx)*fx;
cov = Kyy-Kyx*inv(Kxx)*Kxy;

figure
plot(x,fx,'b+')
hold on 
plot(y,mean,'r*')






