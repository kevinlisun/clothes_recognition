function [ obj, isT ] = SearchingTriplets( rangeMap, realRange, shapeIndex, contour, pos, orien, thres )

    obj.center = pos;
    row = pos(1);
    col = pos(2);
    
    endL = 0;
    endR = 0;
    
    isL = 0;
    isR = 0;
    
    obj.leftChild = [];
    obj.rightChild = [];
    
    iter = 1;
    r = 3;
    r_normal = 15;
            
    while iter<thres && endL*endR==0
        
        if iter == 1
            currentL = pos;
            currentR = pos;
            
            currentPatch = rangeMap(max(1,currentL(1)-r):r:min(size(rangeMap,1),currentL(1)+r),max(1,currentL(2)-r):r:min(size(rangeMap,2),currentL(2)+r));
            if size(currentPatch,1)*size(currentPatch,2)~=9
                endL = 1; endR = 1;
            else          
                move = getDirection( currentPatch );           
                currentL = currentL + move;          
                currentR = currentR - move;
            end
        end
        
        if endL == 0
            currentPatch = rangeMap(max(1,currentL(1)-r):r:min(size(rangeMap,1),currentL(1)+r),max(1,currentL(2)-r):r:min(size(rangeMap,2),currentL(2)+r));
            if size(currentPatch,1)*size(currentPatch,2)~=9
                endL = 1;
            else
                moveL = getDirection( currentPatch );
                currentL = currentL + moveL;
            end
            
            if shapeIndex(currentL(1),currentL(2))~=7 && shapeIndex(currentL(1),currentL(2))~=8
                endL = 1;
            elseif contour(currentL(1),currentL(2))==1
                isL = 1; obj.leftChild = currentL; endL = 1;
            elseif contour(currentL(1),currentL(2))==2 % clothes boundaries
                isL = 2; obj.leftChild = currentL; endL = 1;
            end
        end
        
        if endR == 0
            
            currentPatch = rangeMap(max(1,currentR(1)-r):r:min(size(rangeMap,1),currentR(1)+r),max(1,currentR(2)-r):r:min(size(rangeMap,2),currentR(2)+r));
            if size(currentPatch,1)*size(currentPatch,2)~=9
                endR = 1;
            else
                %currentR = currentR + getDirection( currentPatch );
                moveR = getDirection( currentPatch );
                if endL == 0 && sum(moveL.*moveR)>=0
                    moveR = -moveL;
                end
                currentR = currentR + moveR;
            end
            
            if shapeIndex(currentR(1),currentR(2))~=7 && shapeIndex(currentR(1),currentR(2))~=8
                endR = 1;
            elseif contour(currentR(1),currentR(2))==1
                isR = 1; obj.rightChild = currentR; endR = 1;
            elseif contour(currentR(1),currentR(2))==2 % clothes boundaries
                isR = 2; obj.rightChild = currentR; endR = 1;
            end
        end
        
        iter = iter + 1;
    end
            
         
    isT = isL + isR;
    
    if isT >= 2 && ~isempty(obj.leftChild) && ~isempty(obj.rightChild)
        
        if isT > 2 % occulsition situation
            obj.abheight = rangeMap(obj.center(1),obj.center(2))-max( rangeMap(obj.leftChild(1),obj.leftChild(2)), rangeMap(obj.rightChild(1),obj.rightChild(2)) );
        else
            obj.abheight = rangeMap(obj.center(1),obj.center(2))-0.5*( rangeMap(obj.leftChild(1),obj.leftChild(2))+rangeMap(obj.rightChild(1),obj.rightChild(2)) );
        end
        
        obj.height = rangeMap(obj.center(1),obj.center(2));
        obj.width = sqrt(sum((obj.center-obj.leftChild).^2)) + sqrt(sum((obj.center-obj.rightChild).^2));
        
        if obj.width >= 50 || obj.width <= 5
            isT = 0;
            return;
        end
        
        obj.score = obj.height/obj.width;
        x0 = obj.center(2);
        y0 = obj.center(1);
        
        obj.position2D = [ x0, y0 ];
        
        % compute surface normal
% % %         vec_x = [x0-1,y0,realRange(y0,x0-1)]-[x0+1,y0,realRange(y0,x0+1)];
% % %         vec_y = [x0,y0-1,realRange(y0-1,x0)]-[x0,y0+1,realRange(y0+1,x0)];
% % %         normal = cross(vec_x,vec_y);
% % %         r_normal = round(obj.width/2);
        centerPatch = realRange(max(1,obj.center(1)-r_normal):1:min(size(realRange,1),obj.center(1)+r_normal),max(1,obj.center(2)-r_normal):1:min(size(realRange,2),obj.center(2)+r_normal));
        normal = GetPatchNormal( centerPatch );
        obj.normal = normal;
        
        x1 = obj.leftChild(2);
        y1 = obj.leftChild(1);
        x2 = obj.rightChild(2);
        y2 = obj.rightChild(2);
        
        obj.leftChild2D = [ x1, y1 ];
        obj.rightChild2D = [ x2, y2 ];

% % %         rotation = atan( (y2-y1)/(x2-x1) )/pi*180;
% % %         obj.rotation = rotation;
    else
        isT = 0;
    end
    
    
            
            
        