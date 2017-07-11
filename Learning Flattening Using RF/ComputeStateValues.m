function [ value ] = ComputeStateValues( model, canonical )
    
    % P1 is the state x, P2 is the caninical state
    P1 = model.cloth_points(:,[1,3]);
    P2 = canonical.cloth_points(:,[1,3]);
    
    % initialize the rotation theta and shift [ a, b ]
    theta = 0;
    a = 0;
    b = 0;
    iterMax = 10000;
    rate = 10e-7;
    thres = 10e-4;
    Ft = zeros(1,iterMax);
    
    % gradient desent
    iter = 1; 
    while iter < iterMax
        phaseA = P1(:,1)*cos(theta)+P1(:,2)*sin(theta)+a-P2(:,1);
        phaseB = -P1(:,1)*sin(theta)+P1(:,2)*cos(theta)+b-P2(:,2);
        
        % computer the partical derivative of thetha, a, b
        pd_theta = sum( 2*phaseA.*(P1(:,1)*-sin(theta)+P1(:,2)*cos(theta)) + 2*phaseB.*(-P1(:,1)*cos(theta)-P1(:,2)*sin(theta)) );
        pd_a = sum( 2*phaseA );
        pd_b = sum( 2*phaseB );
        % update theta, a, b 
        theta = theta - rate*pd_theta;
        a = a - rate*pd_a;
        b = b - rate*pd_b;
        
        % compute onject function in State(t+1)
        phaseA = P1(:,1)*cos(theta)+P1(:,2)*sin(theta)+a-P2(:,1);
        phaseB = -P1(:,1)*sin(theta)+P1(:,2)*cos(theta)+b-P2(:,2);
        
        Ft(iter) = sum( phaseA.^2 + phaseB.^2 );
        
        % halting criterion
        if iter > 1 && abs(Ft(iter) - Ft(iter-1)) < thres
            break;
        end
        iter = iter + 1;
    end
    value = Ft(iter);
    figure;
    plot(1:iterMax, Ft, 'b*');
    close;
    