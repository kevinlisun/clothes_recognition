% TEST1 Shows how to use the library to compute
%   a minimum cut on the following graph:
%
%                SOURCE
%		       /       \
%		     1/         \6
%		     /      4    \
%		   node0 -----> node1
%		     |   <-----   |
%		     |      3     |
%		     \            /
%		     5\          /2
%		       \        /
%		          SINK
%
%   (c) 2008 Michael Rubinstein, WDI R&D and IDC
%   $Revision: 140 $
%   $Date: 2008-09-15 15:35:01 -0700 (Mon, 15 Sep 2008) $
%

% pouziji se hrany: source->node0, node1->node0, node1->sink (1 + 3 + 2);
% tim se zamezi tomu, aby neco teklo ze source do sink

A = sparse(2,2);
A(1,2)=6;
A(2,1)=3;

Df = [1 6; 5 2];
T = sparse(Df');
T(1,1)=1;
T(2,1)=6;
T(1,2)=5;
T(2,2)=2;

[flow,labels] = maxflow(A,T)
