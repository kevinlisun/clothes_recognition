function comp = subset_comp(setSize, subset)

% build characteristic function for complement
charFunc = true(setSize, 1);
charFunc(subset) = false;

% convert characteristic function to set members
comp = find(charFunc);

end
