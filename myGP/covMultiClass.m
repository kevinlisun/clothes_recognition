function [ K ] = covMultiClass(hyp, para, X1, X2, i)

kernel = para.kernel;
c = para.c;

if strcmp(kernel,'linear')
    Kci = computeCov(X1, X2, para);
end


if nargin == 4
    Kci = feval(kernel, hyp, X1, X2);
elseif nargin == 5
    Kci = feval(kernel, hyp, X1, X2, i);
else
    disp('ERROR: Too many input variables!');
end


% % if strcmp(kernel,'LINard')
% %     if nargin == 4
% %         Kci = feval(@covLINard, hyp, X1, X2);
% %     elseif nargin == 5
% %         Kci = feval(@covLINard, hyp, X1, X2, i);
% %     else
% %         disp('ERROR: Too many input variables!');
% %     end       
% % end

if c == 2
    K = Kci;
elseif c > 2
    Kc = {Kci};
    Kc = repmat(Kc, [c,1]);
    
    K = constructBlockDiag(Kc);
else
    disp('ERROR: c must larger than 2!');
end

