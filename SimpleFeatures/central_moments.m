function n_pq = central_moments(p,q,A)

p = double(p);
q = double(q);
A = im2double(A);

%A(isnan(A)) = 0;

moo=nansum(nansum(A));

sz = size( A );
x = ( 1:sz(2));
y = ( 1:sz(1)).'; %'
x = x - mean(x);
y = y - mean(y);
mu_pq = nansum( reshape( bsxfun( @times, bsxfun( @times, A, x.^p ), y.^q ), [], 1 ) );


gamma = (0.5*(p+q)) + 1;
n_pq = mu_pq / (moo^gamma);