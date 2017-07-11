function [ modelA modelB ] = Joint2VerticalPatchesC1( modelA, modelB )

    % joint the vertical model
    % ModelA refers to north one, model B refers to the south one

    if isempty(modelA) || isempty(modelB)
        return;
    end
    
    B_A(:,:,1) = reshape(modelA.B(:,1),[modelA.bnum_u,modelA.bnum_w]);
    B_A(:,:,2) = reshape(modelA.B(:,2),[modelA.bnum_u,modelA.bnum_w]);
    B_A(:,:,3) = reshape(modelA.B(:,3),[modelA.bnum_u,modelA.bnum_w]);
    B_B(:,:,1) = reshape(modelB.B(:,1),[modelB.bnum_u,modelB.bnum_w]);
    B_B(:,:,2) = reshape(modelB.B(:,2),[modelB.bnum_u,modelB.bnum_w]);
    B_B(:,:,3) = reshape(modelB.B(:,3),[modelB.bnum_u,modelB.bnum_w]);
    
    %%

    %% C1 continutiy
    B_A(end,2:end-1,:) = (B_A(end-1,2:end-1,:) + B_B(2,2:end-1,:)) / 2;
    B_B(1,2:end-1,:) = B_A(end,2:end-1,:);
    %%
    
    %%
    
    modelA.B(:,1) = reshape(B_A(:,:,1),[modelA.bnum_u*modelA.bnum_w,1]);
    modelA.B(:,2) = reshape(B_A(:,:,2),[modelA.bnum_u*modelA.bnum_w,1]);
    modelA.B(:,3) = reshape(B_A(:,:,3),[modelA.bnum_u*modelA.bnum_w,1]);
    modelB.B(:,1) = reshape(B_B(:,:,1),[modelB.bnum_u*modelB.bnum_w,1]);
    modelB.B(:,2) = reshape(B_B(:,:,2),[modelB.bnum_u*modelB.bnum_w,1]);
    modelB.B(:,3) = reshape(B_B(:,:,3),[modelB.bnum_u*modelB.bnum_w,1]);
