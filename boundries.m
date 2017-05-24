function [objective_boundries] = boundries(matrix)
objective_boundries = zeros(size(matrix));
for i = 1:size(matrix,1)
        for j = 1:size(matrix,2)
            P = matrix(i, j);
           
            if P ~= 0
                if i - 1 > 0
                    if matrix(i-1,j) == 0
                        objective_boundries(i,j) = P;
                    elseif i + 1 <= size(matrix,1)
                            if matrix(i+1,j) == 0
                                objective_boundries(i,j) = P;
                            elseif j - 1 > 0
                                if matrix(i,j-1) == 0
                                    objective_boundries(i,j) = P;
                                elseif j+1<= size(matrix,2)
                                    if matrix(i,j+1) == 0
                                        objective_boundries(i,j) = P;
                                    end
                                else
                                    objective_boundries(i,j) = P;
                                end
                            else
                                objective_boundries(i,j) = P;
                            end
                        else
                            objective_boundries(i,j) = P;
                    end
                    else
                        objective_boundries(i,j) = P;
                end
            end          
        end
end
return;
end