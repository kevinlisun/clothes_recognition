function [means, vars, groupMeans, groupVars] = learn_gauss_model(data, groups)

[dimData, numData] = size(data);
numGroups = max(groups);

% create data groups
groupData = cell(numGroups, 1);
for j = 1:numData
    for i = 1:dimData
        g = groups(i);
        groupData{g} = cat(2, groupData{g}, data(i,j));
    end
end

% compute distributions for groups
groupMeans = cellfun(@(g) mean(g), groupData);
groupVars = cellfun(@(g) var(g), groupData);

% copy distributions to individual members of groups
means = zeros(1, dimData);
vars = zeros(1, dimData);
for i = 1:dimData
    g = groups(i);
    means(i) = groupMeans(g);
    vars(i) = groupVars(g);
end

end
