function [ratio] = eccentricity(matrix, center)
x1 = double(center(1,1));
y1 = double(center(2,1));
max = 1;
min = 1000;

for i = 1:length(matrix(1,:))
    x = matrix(1,i);
    y = matrix(2,i);
    c = ((x-x1)^2 + (y-y1)^2)^(1/2);
    if c > max
        if c < 1
            c = 1;
        end
        max = c;
    end
    if c < min
        if c <1
            c = 1;
        end
        min = c;
    end
end
ratio = min/max;
return
end