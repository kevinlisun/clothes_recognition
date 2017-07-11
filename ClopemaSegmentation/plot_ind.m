function plot_ind(pos, placement, varargin)

ind = 1:size(pos,2);
txt = num2str_mat(ind);
plot_text(pos, txt, placement, varargin{:});

end
