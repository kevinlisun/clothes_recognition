function FirstDerivX = FirstDerivatives(hyp, para, model, N, myFx)

tic
disp('caculating the deritives d(p(y|X,theta}d(theta) ...');
FirstDerivX = feval(myFx, hyp, para, model, []);
disp(['derivative at each dimention is: ', num2str(FirstDerivX)]);
toc

% % % for iVar=1:N
% % %     [ FirstDerivX(iVar) ] = feval(myFx, hyp, para, model, iVar);
% % %     disp(['derivative at ',num2str(iVar),'th dimention is ', num2str(FirstDerivX(iVar))]);
% % % end

% % % 
% % % coreNum = 12;
% % % 
% % % for i = 1:coreNum
% % %     batch{i} = i:coreNum:N;
% % % end
% % % 
% % % FirstDerivX = cell(coreNum,1);
% % % for i = 1:coreNum
% % %     FirstDerivX{i} = zeros(1,N);
% % % end
% % % 
% % % parfor i = 1:coreNum
% % %     for j = 1:length(batch{i})
% % %         FirstDerivX{i}(batch{i}(j)) = feval(myFx, hyp, para, model, batch{i}(j));
% % %         disp(['derivative at ',num2str((batch{i}(j))),'th dimention is ', num2str(FirstDerivX{i}(batch{i}(j)))]);
% % %     end
% % % end
% % % 
% % % FirstDerivX = cell2mat(FirstDerivX);
% % % FirstDerivX = sum(FirstDerivX,1);




