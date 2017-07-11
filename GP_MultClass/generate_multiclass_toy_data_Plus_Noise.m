function [X,t] = generate_multiclass_toy_data_Plus_Noise(n);

u=4*rand(n,2)-2;
i=find( (u(:,1).^2 + u(:,2).^2 > .1) & (u(:,1).^2 + u(:,2).^2 < .5) );
j=find( (u(:,1).^2 + u(:,2).^2 > .6) & (u(:,1).^2 + u(:,2).^2 < 1) );
X=u([i;j],:);
t=ones(size(i,1),1);
t=[t;2*ones(size(j,1),1)];
x = 0.1.*randn(size(i,1),2);
k = find (x(:,1).^2 + x(:,2).^2 < 0.1);
X=[X;x(k,:)];
t=[t;3*ones(size(k,1),1)];
X=[X randn(size(X,1),8)];

