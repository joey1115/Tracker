function [objective_center]= centroid(matrix, numb)
x_sum = 0;
y_sum = 0;
count = 0;
    for i = 1:size(matrix,1)
        for j = 1:size(matrix,2)
            if matrix(i,j) == numb
                x_sum = x_sum + i;
                y_sum = y_sum + j;
                count = count + 1;
            end
        end
    end
x_av = uint8(x_sum / count);
y_av = uint8(y_sum / count);
objective_center = [x_av, y_av];
return;
end