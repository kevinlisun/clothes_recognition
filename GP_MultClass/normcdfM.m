function o = normcdfM(x,m,s)
%Computes elementwise normal cdf's at x with mean m and standard
%deviation s
if nargin == 1
  z = x;
elseif nargin == 2
  z = (x-m);
else
  z = (x-m)./s;
end
o = 0.5 * erfc(-z ./ sqrt(2));
