function [h, Hist] = plot_hists(Data, outRatio, nBins, annotQuant)

mData = numel(Data);

if ~exist('nBins', 'var'), nBins = 40; end
if ~exist('annotQuant', 'var'), annotQuant = cell(mData, 1); end

% use specified count of bins adjusted to data without outliers
Quant = zeros(mData, 2);
for i = 1:mData
    Quant(i,:) = quantile(Data{i}, [outRatio, 1-outRatio]);
end
lb = min(Quant(:,1));
ub = max(Quant(:,2));
bins = linspace(lb, ub, nBins);

% build histograms for all data rows
Hist = zeros(mData, nBins);
for i = 1:mData
    Hist(i,:) = hist(Data{i}, bins);
end

% plot histograms as barcharts
h = bar(bins', Hist');

yMax = max(Hist(:));
cmap = colormap();

% plot annotation quantiles
for i = 1:mData
    if numel(annotQuant{i}) > 0
        xi = quantile(Data{i}, annotQuant{i});
        for j = 1:numel(xi)
            line([xi(j), xi(j)], [0, yMax], 'Color', cmap(i,:));
        end
    end
end

end
