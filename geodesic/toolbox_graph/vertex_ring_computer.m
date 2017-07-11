% Adaptation of function 'compute_vertex_ring.m'. Only computes required
% elements. Original function is copyright:
% 'Copyright (c) 2004 Gabriel Peyr�'
% Adaptation by Demian Till.

classdef vertex_ring_computer
    properties
        i
        j
    end
    methods
        function obj = vertex_ring_computer(face)
            [tmp,face] = check_face_vertex([],face);
            f = double(face)';
            A = sparse([f(:,1); f(:,1); f(:,2); f(:,2); f(:,3); f(:,3)], ...
                       [f(:,2); f(:,3); f(:,1); f(:,3); f(:,1); f(:,2)], ...
                       1.0);
            % avoid double links
            A = double(A>0);
            [obj.i,obj.j,s] = find(sparse(A));
        end
        function adj = compute_vertex_ring_element(obj, index)
            adj = [];
            for m = 1:length(obj.i)
                if obj.i(m) == index
                    adj(end + 1) = obj.j(m);
                end
            end
        end
    end
end