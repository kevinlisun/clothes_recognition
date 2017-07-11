function h = plot_gauss(mu, sigma, numSigmas, numPts, varargin)

% default range is 3 variances to both directions
if ~exist('numVars', 'var'), numSigmas = 3; end

% default density is 100 points per variance
if ~exist('numPts', 'var'), numPts = 2 * numSigmas * 100; end

x = linspace(mu - numSigmas * sigma, mu + numSigmas * sigma, numPts);
y = normpdf(x, mu, sigma);

h = plot(x, y, varargin{:});

end
