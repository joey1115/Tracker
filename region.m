function [matrix] = region(matrix, position_x, position_y, num)
if  matrix(position_x, position_y) ~= 1
    return;
end
if matrix(position_x, position_y) == 1
    matrix(position_x, position_y) = num;
end
if position_x - 1 > 0
   matrix = region(matrix, position_x - 1, position_y, num);
end
if position_x + 1 <= size(matrix,1)
   matrix = region(matrix, position_x + 1, position_y, num);
end
if position_y - 1 > 0
   matrix = region(matrix, position_x, position_y - 1, num);
end
if position_y + 1 <= size(matrix,2)
   matrix = region(matrix, position_x, position_y + 1, num);
end
    return;
end