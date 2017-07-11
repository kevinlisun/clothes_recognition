function energy = getWrinkleEnergy( wrinklei )

    if isempty(wrinklei.length)+isempty(wrinklei.width)+isempty(wrinklei.height) == 0
        energy = (wrinklei.length) / (wrinklei.width) * (wrinklei.height);
    else
        energy = 0;
    end