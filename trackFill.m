function track_out = trackFill( track )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
track_out = cell(size(track));
for i = 1:size(track,1)
    disp(i)
    if length(track{i,1}) == ((track{i,6}(end)-track{i,6}(1))+1)
        track_out{i,1} = track{i,1};
        track_out{i,2} = track{i,2};
        track_out{i,3} = track{i,3};
        track_out{i,4} = track{i,4};
        track_out{i,5} = track{i,5};
        track_out{i,6} = track{i,6};
    else
        for j = 2:length(track{i,1})
            gap =  track{i,6}(j) - track{i,6}(j-1);
            if gap == 1
                continue
            else
                xstep = (track{i,1}(j) - track{i,1}(j-1))/gap;
                ystep = (track{i,2}(j) - track{i,2}(j-1))/gap;
                tempx = track{i,1}(1:(j-1));
                tempy = track{i,2}(1:(j-1));
                tempvx = track{i,3}(1:(j-1));
                tempvy = track{i,4}(1:(j-1));
                tempID = track{i,5}(1:(j-1));
                tempframe = track{i,6}(1:(j-1));
                for k = 1:(gap - 1)
                    tempx(end+1) = tempx(end) + xstep;
                    tempy(end+1) = tempy(end) + ystep;
                    tempvx(end+1) = tempvx(end);
                    tempvy(end+1) = tempvy(end);
                    tempID(end+1) = 0;
                    tempframe(end+1) = tempframe(end) + 1;
                end
                track_out{i,1} = [tempx,track{i,1}(j:end)];
                track_out{i,2} = [tempy,track{i,2}(j:end)];
                track_out{i,3} = [tempvx,track{i,3}(j:end)];
                track_out{i,4} = [tempvy,track{i,4}(j:end)];
                track_out{i,5} = [tempID,track{i,5}(j:end)];
                track_out{i,6} = [tempframe,track{i,6}(j:end)];
            end
        end
    end
end
end

