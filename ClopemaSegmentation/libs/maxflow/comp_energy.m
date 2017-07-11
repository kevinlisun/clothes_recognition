function E = comp_energy(Df, Vf, neigh, lab)

% unary energy
Ed = sum(Df(1,lab==1)) + sum(Df(2,lab==0));

% binary energy
ineq = lab(neigh(:,1)) ~= lab(neigh(:,2));
Ev = sum(Vf(ineq)) / 2;

% sum both energies
E = Ed + Ev;

end
