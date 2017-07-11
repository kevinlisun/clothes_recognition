function [ Model ] = Joint4PatchesWithC1( Model, pos )

    row = pos(1);
    col = pos(2);
    
    patchNW = Model{row,col};
    patchNE = Model{row,col+1};
    patchSW = Model{row+1,col};
    patchSE = Model{row+1,col+1};
    
    %% joint the boundaries
    if isempty(patchNW) == 0 && isempty(patchNE) == 0
        [ patchNW patchNE ] = Joint2HorizontalPatchesC1( patchNW, patchNE );
    end
    % joint the South West and South East Patch
    if isempty(patchSW) == 0 && isempty(patchSE) == 0
        [ patchSW patchSE ] = Joint2HorizontalPatchesC1( patchSW, patchSE );
    end
    % joint the North West and South West Patch
    if isempty(patchNW) == 0 && isempty(patchSW) == 0
        [ patchNW patchSW ] = Joint2VerticalPatchesC1( patchNW, patchSW );
    end
     % joint the North East and South East Patch
    if isempty(patchNE) == 0 && isempty(patchSE) == 0
        [ patchNE patchSE ] = Joint2VerticalPatchesC1( patchNE, patchSE );
    end
    
    [ patchNW patchNE patchSW patchSE ] = Adjust4PatchesCenterC1( patchNW, patchNE, patchSW, patchSE );
    

    [ patchNW patchNE patchSW patchSE ] = Adjust4InteriorPoints( patchNW, patchNE, patchSW, patchSE );

    
    if isempty(patchNW) == 0 && isempty(patchNE) == 0
        [ patchNW patchNE ] = Joint2HorizontalPatchesC1( patchNW, patchNE );
    end
    % joint the South West and South East Patch
    if isempty(patchSW) == 0 && isempty(patchSE) == 0
        [ patchSW patchSE ] = Joint2HorizontalPatchesC1( patchSW, patchSE );
    end
    % joint the North West and South West Patch
    if isempty(patchNW) == 0 && isempty(patchSW) == 0
        [ patchNW patchSW ] = Joint2VerticalPatchesC1( patchNW, patchSW );
    end
     % joint the North East and South East Patch
    if isempty(patchNE) == 0 && isempty(patchSE) == 0
        [ patchNE patchSE ] = Joint2VerticalPatchesC1( patchNE, patchSE );
    end
    
    [ patchNW patchNE patchSW patchSE ] = Adjust4PatchesCenterC1( patchNW, patchNE, patchSW, patchSE );
    

    Model{row,col} = patchNW;
    Model{row,col+1} = patchNE;
    Model{row+1,col} = patchSW;
    Model{row+1,col+1} = patchSE;
         
    
    
    
        