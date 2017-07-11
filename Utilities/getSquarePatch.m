function curI = getSquarePatch( I, pos, template )

    pos = round(pos);
    irow = pos(1);
    icol = pos(2);
    templateH = template(1);
    templateW = template(2);
    
    curI = I( max(1,irow-fix(templateH/2)):min(size(I,1),irow+fix(templateH/2)), max(1,icol-fix(templateW/2)):min(size(I,2),icol+fix(templateW/2)), :);