function lambda = linsearch(hyp, para, model, lambda, D, myFx)

  MaxIt = 100;
  Toler = 0.000001;

  iter = 0;
  bGoOn = true;
  while bGoOn
    iter = iter + 1;
    if iter > MaxIt
      lambda = 0;
      break
    end

    h = 0.01 * (1 + abs(lambda));
    f0 = myFxEx(hyp, para, model, D, lambda, myFx);
    fp = myFxEx(hyp, para, model, D, lambda+h, myFx);
    fm = myFxEx(hyp, para, model, D, lambda-h, myFx);
    deriv1 = (fp - fm) / 2 / h;
    deriv2 = (fp - 2 * f0 + fm) / h ^ 2;
    if deriv2 == 0
      break
    end
    diff = deriv1 / deriv2;
    lambda = lambda - diff;
    if abs(diff) < Toler
      bGoOn = false;
    end
  end
