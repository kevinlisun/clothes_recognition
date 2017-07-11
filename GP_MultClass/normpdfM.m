function o = normpdfM(x,m,s)
%Computes elementwise normal pdfs at x with mean m and standard
%deviation s
%Constant term
if nargin == 2
  s = 1;
elseif nargin == 1
  s = 1;
  m = 0;
end
o = 1./sqrt(2*pi*(s.^2));
o = o.*exp(-((x-m).^2)./(2*(s.^2)));
