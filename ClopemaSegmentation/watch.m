function t = watch(name)

% persistent vector of timestamps
persistent running;

start = exist('name', 'var');

% start previous measurement
if (islogical(running) && running) || ~start
    t = toc;
    running = false;
    fprintf('%f\n', t);
end

% start next measurement
if start
    fprintf('%s: ', name);
    running = true;
    tic;
end

end
