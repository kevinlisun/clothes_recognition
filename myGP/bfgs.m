function [hyp,maxloglikelihood,Iters] = bfgs(hyp, para, X, y,  gradToler, fxToler, DxToler, MaxIter, myFx)
% Function bfgs performs multivariate optimization using the
% Broyden-Fletcher-Goldfarb-Shanno method.
%
% Input
%
% N - number of variables
% X - array of initial guesses
% gradToler - tolerance for the norm of the slopes
% fxToler - tolerance for function
% DxToler - array of delta X tolerances
% MaxIter - maximum number of iterations
% myFx - name of the optimized function
%
% Output
%
% X - array of optimized variables
% F - function value at optimum
% Iters - number of iterations
%

[ K ] = covMultiClass(hyp, para, X, []);
[ model ] = LaplaceApproximation(hyp, para, K, X, y);

N = length(hyp);

B = eye(N,N);

bGoOn = true;
Iters = 0;
% calculate initial gradient
grad1 =  FirstDerivatives(hyp, para, model, N, myFx);
grad1 = grad1';


while bGoOn

  Iters = Iters + 1;
  if Iters > MaxIter
    break;
  end
  
  [ K ] = covMultiClass(hyp, para, X, []);
  [ model ] = LaplaceApproximation(hyp, para, K, X, y);
  model.X = X;
  model.y = y;
  model.K = K;

  S = -1 * B * grad1;
  S = S' / norm(S); % normalize vector S

  lambda = .01;
  lambda = linsearch(hyp, para, model, lambda, S, myFx);
  % calculate optimum X() with the given Lambda
  d = lambda * S;
  hyp = hyp + d;
  % get new gradient
  grad2 =  FirstDerivatives(hyp, para, model, N, myFx);

  grad2 = grad2';
  g = grad2 - grad1;
  grad1 = grad2;

  % test for convergence
  for i = 1:N
    if abs(d(i)) > DxToler(i)
      break
    end
  end

  if norm(grad1) < gradToler
    break
  end

  d = d';
  x1 = d * d';
  x2 = d' * g;
  x3 = d * g';
  x4 = g * d';
  x5 = g' * B * g;
  x6 = d * g' * B;
  x7 = B * g * d';
  B = B + (1 + x5 / x2) * x1 / x2 - x6 / x2 - x7 / x2;
  % break
  
  if para.flag
      figure(1); clf;
      title('result of model selection');
      subplot(1,3,1);
      title('-log p(y|X,theta');
      xlabel('optimization iteration i')
      ylabel('-log likelihood');
      loglikelihood(Iters) = feval(myFx, hyp, para, model);
      plot(1:Iters,loglikelihood,'--ro');
      
      subplot(1,3,2);
      title('d -log p(y|X,theta d theta');
      xlabel('hyper parameters dimention i')
      ylabel('gradient -log likelihood by theta i');
      plot(1:N, grad2,'g^');
      
      subplot(1,3,3);
      title('hyper paramters ell in Eard kernal');
      xlabel('feature dimention i');
      ylabel('values');
      plot(1:N,hyp(1:end), 'b+');
      pause(0.1);
  end
end

maxloglikelihood = feval(myFx, hyp, para, model);

if para.flag
    figure(1); clf;
    title('result of model selection');
    subplot(1,3,1);
    title('-log p(y|X,theta');
    xlabel('optimization iteration i')
    ylabel('-log likelihood');
    loglikelihood(Iters) = feval(myFx, hyp, para, model);
    plot(1:Iters,loglikelihood,'--ro');
    
    subplot(1,3,2);
    title('d -log p(y|X,theta d theta');
    xlabel('hyper parameters dimention i')
    ylabel('gradient -log likelihood by theta i');
    plot(1:N, grad2,'g^');
    
    subplot(1,3,3);
    title('hyper paramters ell in Eard kernal');
    xlabel('hyper parameters dimention i');
    ylabel('values');
    plot(1:N,hyp, 'b+');
    pause(0.1);
    
    c = clock;
    print(1, strcat('model_', num2str(c(1)), '_', num2str(c(2)), '_', num2str(c(3)), '_', num2str(c(4)), '_', num2str(c(5)), '_', num2str(c(6))), '-dpdf');
end

% end




