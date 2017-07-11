function [loss gloss] = lossFunc(weights)

weights = weights';

global x
global B
global codes

loss = sum(sqrt(sum((x-codes*B).^(2),2)),1) ;
loss = loss + sum( sqrt( sum( (x*B'.* repmat(weights,[size(codes,1),1]) .* codes).^2, 2) ), 1 );

disp(['loss value is :', num2str(loss), '...']);
weights
% % figure(1)
% % subplot(1,2,1)
% % plot(1:length(weights), weights, 'b+')
%pause(1)
    
if nargout > 1
    
    for i = 1:length(weights)
        weighti = zeros(size(weights));
        weighti(i) = weights(i);
        gloss(1,i) = sum( sqrt( sum( (x*B'.* repmat(weighti,[size(codes,1),1]) .* codes).^2, 2) ), 1 );
    end
% %     figure(1)
% %     subplot(1,2,2)
% %     plot(1:length(gloss), gloss, 'r^')
end




