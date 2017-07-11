function [ maxQ, maxQaction ] = getMaxQ_GP( state_tt, normVec, net )

    seg = pi/180;
    action = (-pi:seg:pi)';
    action(1) = [];
    
    % cos(action), sin(action)
    input = [ repmat(state_tt,[length(action),1]), action ];
    
    input = input./repmat(normVec,[size(input,1),1]);
    input(:,1:end-2) = input(:,1:end-2)*2 - 1;
    
    Q = ( net( input','useParallel', 'yes', 'useGPU', 'yes' ) )';
    
    % gaussian smoothing
% %     sizeQ = length(Q);
% %     Q = repmat(Q,[3,1]);
% %     gauss_filter = fspecial('gaussian',[11 1], 0.9);
% %     conv(Q,gauss_filter,'same');
% %     Q = Q(sizeQ+1:2*sizeQ);
    
    [ maxQ b] = max(Q);
    
    maxQaction = action(b);