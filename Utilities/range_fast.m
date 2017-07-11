function range = range_fast(p, q, dispH, dispV, mask)

tic 

if nargin < 5
	mask = ones(size(dispH,1),size(dispH,2));
end

if size(p,1) ~= 3 || size(p,2) == 4
    p = reshape(p, 4,3)';
end

if size(q,1) ~= 3 || size(q,2) == 4
    q = reshape(q, 4,3)';
end

a = p(1,1);
c = p(2,2);

%X3D = zeros(3,size(dispH,2)*size(dispH,1));
range = zeros(size(dispH,1), size(dispH,2));

%iter = 1;
for n = 1:size(dispH,2)
    for m = 1:size(dispH,1)
        if mask(m,n) == 1
            x1 = n;
            y1 = m;
            x2 = x1 + dispH(m,n);
            y2 = y1 + dispV(m,n);
            
            b = p(1,3) - x1;
            d = p(2,3) - y1;
            e = q(1,1) - x2*q(3,1);
            f = q(1,2) - x2*q(3,2);
            g = q(1,3) - x2*q(3,3);
            h = q(2,1) - y2*q(3,1);
            i = q(2,2) - y2*q(3,2);
            j = q(2,3) - y2*q(3,3);
            x = x2*q(3,4) - q(1,4);
            y = y2*q(3,4) - q(2,4);
            
            % XUp = (d*f*h - c*g*h - d*e*i + c*e*j)*(-(d*i*x) + c*j*x + d*f*y - c*g*y) + b^2*((f*h - e*i)*(-(i*x) + f*y) + c^2*(e*x + h*y)) + a*b*((-(g*i) + f*j)*(i*x - f*y) + c*d*(f*x + i*y) - c^2*(g*x + j*y));
            % YUp = (b^2*(f*h - e*i) + d*(d*f*h - c*g*h - d*e*i + c*e*j))*(h*x - e*y) + a*b*((c*d*e + g*h*i - 2*f*h*j + e*i*j)*x + (c*d*h + f*g*h - 2*e*g*i + e*f*j)*y) + a^2*((g*i - f*j)*(-(j*x) + g*y) + d^2*(f*x + i*y) - c*d*(g*x + j*y));
            ZUp = c*(-(d*f*h) + c*g*h + d*e*i - c*e*j)*(h*x - e*y) - a*b*((f*h - e*i)*(-(i*x) + f*y) + c^2*(e*x + h*y)) + a^2*((g*i - f*j)*(i*x - f*y) - c*d*(f*x + i*y) + c^2*(g*x + j*y));
            divisor = b^2*(c^2*(e^2 + h^2) + (f*h - e*i)^2) + (d*f*h - c*g*h - d*e*i + c*e*j)^2 - 2*a*b*(-(c*d*(e*f + h*i)) + (f*h - e*i)*(-(g*i) + f*j) + c^2*(e*g + h*j)) + a^2*(d^2*(f^2 + i^2) + (g*i - f*j)^2 - 2*c*d*(f*g + i*j) + c^2*(g^2 + j^2));
            
            %X3D(1,iter) = XUp/divisor;
            %X3D(2,iter) = YUp/divisor;
            %X3D(3,iter) = ZUp/divisor;
            
            range(m,n) = ZUp/divisor;
            
            %iter = iter + 1;
        end
    end
end


toc

time_d2r = toc
