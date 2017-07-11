function fig2png(outputFilePath)

set(gca, 'Visible', 'off');
set(gca, 'YDir', 'reverse');
set(gca, 'position', [0 0 1 1], 'units', 'normalized');
saveas(gcf, outputFilePath);

end
