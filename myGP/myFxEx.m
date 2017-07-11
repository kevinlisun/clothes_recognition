function y = myFxEx(hyper, para, model, DeltaX, lambda, myFx)

  hyper = hyper + lambda * DeltaX;
  y = feval(myFx, hyper, para, model);

% end