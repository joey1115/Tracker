function [sum] = area_sum(matrix)
sum = 0;
for i = 1:size(matrix(:,1))
    sum = sum + matrix(i,1);
end
return
end