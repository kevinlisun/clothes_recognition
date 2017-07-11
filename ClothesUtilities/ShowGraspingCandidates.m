function ShowGraspingCandidates( rangeMap, candidates, showNum )

    figure(1)
    subplot(2,2,4);
    surf(rangeMap);
    [ oy ox ]  = find(~isnan(rangeMap));
    ox = mean(ox);
    oy = mean(oy);
    r = 0.4*size(rangeMap,1);
    
    axis([ox - r, ox + r, oy - r, oy + r, min(rangeMap(:)), max(rangeMap(:))]);
    view(2)
    camlight right;
    lighting phong;
    shading interp
    hold on;
    title('grasping candidates on fitted range surface');
    
% %     for i = 1:length(candidates)
% %         obj = candidates{i};
% % %         center = obj.center;
% % %         leftChild = obj.leftChild;
% % %         rightChild = obj.rightChild;
% % %         
% % %         c_row = center(1);
% % %         c_col = center(2);
% % %         c_depth = rangeMap(c_row,c_col);
% % %         
% % %         l_row = leftChild(1);
% % %         l_col = leftChild(2);
% % %         l_depth = rangeMap(l_row,l_col);
% % %         
% % %         r_row = rightChild(1);
% % %         r_col = rightChild(2);
% % %         r_depth = rangeMap(r_row,r_col);
% % %         
% % %         % draw center, left, right point
% % %         plot3(c_col,c_row,c_depth,'*r');
% % %         hold on;
% % %         plot3(l_col,l_row,l_depth,'*g');
% % %         hold on;
% % %         plot3(r_col,r_row,r_depth,'*g');
% % %         hold on;
% % %         % draw connecting line
% % %         
% % %         line1 = DrawConnections(zeros(size(rangeMap)), l_row, l_col, c_row, c_col, 1);
% % %         [line_row line_col] = find(line1==1);
% % %         line_depth = diag(rangeMap(line_row,line_col));
% % %         plot3(line_col,line_row,line_depth,'-y');
% % %         
% % %         hold on;
% % %         
% % %         line2 = DrawConnections(zeros(size(rangeMap)), r_row, r_col, c_row, c_col, 1);
% % %         [line_row line_col] = find(line2==1);
% % %         line_depth = diag(rangeMap(line_row,line_col));
% % %         plot3(line_col,line_row,line_depth,'-y');
% % %         hold on;
% %         
% %         scoreArry(i,1) = obj.score;
% %         
% %         
% %        
% %     end
% %     
% %     %% draw normal
% %     [ a score_order ] = sort(scoreArry,'descend');

    score_order = 1:showNum;
    
    for i = 1:min(showNum,length(score_order))
        obj = candidates{score_order(i)};
        P = [obj.center(2),obj.center(1),rangeMap(obj.center(1),obj.center(2))];
        if i == 1
            V = obj.normal*150;
        else
            V = obj.normal*50;
        end
        p1 = P;
        p2 = P+V;
        arrow3d(p1,p2,20,'cylinder',[0.5,0.5]);
        %arrow(P,V,'b')
        hold on;
    end
    
    hold off
    
        