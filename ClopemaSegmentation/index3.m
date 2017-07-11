function ind = index3(height, width, ind)

hw = height * width;

if size(ind, 1) == 1
    ind = [ind, ind+hw, ind+2*hw];
else
    ind = [ind; ind+hw; ind+2*hw];
end

end
