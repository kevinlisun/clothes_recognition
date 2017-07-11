function dist = chordLength( points, n )

    dist = 0;
    for i = 2:n
        dist = dist + sqrt(1+(points(i)-points(i-1))^2);
    end