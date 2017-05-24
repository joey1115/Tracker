function track = spermTrack( ID, file, res, f, lim, err, cof, skip )
% track = spermTrack2( file, res, f, lim, err, cof );
% save track
% Track the sperms
%   Input:
%   file: Index of data files
%   res: Resolution of the image
%   f: Frequency
%   lim: Limit of the speed
%   err: Limit of error
%   cof: Coefficients of the filter
%   Output:
%   Tracks:

% Initialize
data = cell(2,1);
T = 1/f; % Time step

inactive_track = cell(0,6);
active_track = cell(0,6);

% Get first 3 sets of data
x1 = getData(ID, file(1));
data{1,1} = x1;
free_sperm1 = ones(size(x1,1),1) == 1;
x2 = getData(ID, file(2));
data{2,1} = x2;
free_sperm2 = ones(size(x2,1),1) == 1;

for i = 3:length(file)
    disp(file(i))
    % Get data
    xm = getData(ID,file(i));
    data{i,1} = xm;
    % Find new tracks
    
    % Get the possible tracks in frame 1 and 2
    xf1 = x1(free_sperm1,:);
    xf2 = x2(free_sperm2,:);
    tab1 = near(xf1,xf2,lim);
    [row1,col1] = find(tab1);
    [row1,col1] = modify_RW(row1,col1);
    
    % Predict
    vfp = (xf2(col1,:) - xf1(row1,:))/T;
    xfp = xf2(col1,:) + T*vfp;
    
    % Match
    tab2 = near(xfp,xm,err);
    [row2,col2] = find(tab2);
    [row2,col2] = modify_RW(row2,col2);
    
    % Update
    xfr = xm(col2,:) - xfp(row2,:);
    xfk = xfp(row2,:) + cof(1)*xfr;
    vfk = vfp(row2,:) + cof(2)/T*xfr;
    
    % Create new tracks
    new_active_track = cell(0,6);
    new_inactive_track = cell(0,6);
    
    if isempty(row2)
        num1 = 0;
    else
        num1 = size(row2,1);
    end
    
    
    for j = 1:num1
        
        % Check if the sperm is outside the image
        if (xfk(j,1) < 0) || (xfk(j,1) > res(1)) ||...
                (xfk(j,2) < 0) || (xfk(j,2) > res(2))
            
            % Tracks that stop in this frame
            new_inactive_track{end+1,1} =...
                [xf1(row1(row2(j,1),1),1),xf2(col1(row2(j,1),1),1),xfk(j,1)];
            new_inactive_track{end,2} =...
                [xf1(row1(row2(j,1),1),2),xf2(col1(row2(j,1),1),2),xfk(j,2)];
            new_inactive_track{end,3} =...
                [0,vfp(row2(j,1),1),vfk(j,1)];
            new_inactive_track{end,4} =...
                [0,vfp(row2(j,1),2),vfk(j,2)];
            new_inactive_track{end,5} =...
                [row1(row2(j,1),1),col1(row2(j,1),1),col2(j,1)];
            new_inactive_track{end,6} =...
                [i-2, i-1, i];
            
        else
            
            % Tracks that will continue
            new_active_track{end+1,1} =...
                [xf1(row1(row2(j,1),1),1),xf2(col1(row2(j,1),1),1),...
                xfk(j,1)];
            new_active_track{end,2} =...
                [xf1(row1(row2(j,1),1),2),xf2(col1(row2(j,1),1),2),...
                xfk(j,2)];
            new_active_track{end,3} =...
                [0,vfp(row2(j,1),1),vfk(j,1)];
            new_active_track{end,4} =...
                [0,vfp(row2(j,1),2),vfk(j,2)];
            new_active_track{end,5} =...
                [row1(row2(j,1),1),col1(row2(j,1),1),col2(j,1)];
            new_active_track{end,6} =...
                [i-2, i-1, i];
        end
    end
    
    % Extent existing tracks
    xk = ones(0,2);
    vk = ones(0,2);
    
    delta = [];
    exceed_track_index = ones(size(active_track,1),1) == 0;
    
    for j = 1:size(active_track,1)
        last_frame = active_track{j,6}(1,end);
        delta_frame = i - last_frame;
        if delta_frame > skip
            exceed_track_index(j,1) = true;
        else
            xk(end+1,:) = [active_track{j,1}(end),active_track{j,2}(end)];
            vk(end+1,:) = [active_track{j,1}(end),active_track{j,2}(end)];
            delta(1,end+1) = delta_frame;
        end
    end
    
    exceed_track = active_track(exceed_track_index,:);
    active_track = active_track(exceed_track_index==0,:);
    
    vp = vk;
    dT = diag(delta*T);
    xp = xk + dT*vp;
    
    % Match
    if size(delta,2) > 0
        derr = delta'*err;
    else
        derr = err;
    end
    tab3 = near(xp,xm,derr);
    [row3,col3] = find(tab3);
    
    % Update
    xr = xm(col3,:) - xp(row3,:);
    xk = xp(row3,:) + cof(1)*xr;
    temp = diag(cof(2)*delta(row3)./T);
    vk = vp(row3,:) + temp*xr;
    
    % Update database
    temp_active_track = cell(0,6);
    temp_inactive_track = cell(0,6);
    
    if isempty(row3)
        num2 = 0;
        temp_inactive_track = active_track;
    else
        num2 = size(row3,1);
    end
    
    for j = 1:num2
        
        if (xk(j,1) < 0) || (xk(j,1) > res(1)) ||...
                (xk(j,2) < 0) || (xk(j,2) > res(2))
            temp_inactive_track{end+1,1} =...
                [active_track{row3(j),1},xk(j,1)];
            temp_inactive_track{end,2} =...
                [active_track{row3(j),2},xk(j,2)];
            temp_inactive_track{end,3} =...
                [active_track{row3(j),3},vk(j,1)];
            temp_inactive_track{end,4} =...
                [active_track{row3(j),4},vk(j,2)];
            temp_inactive_track{end,5} =...
                [active_track{row3(j),5},col3(j,1)];
            temp_inactive_track{end,6} =...
                [active_track{row3(j),6},i];
        else
            temp_active_track{end+1,1} =...
                [active_track{row3(j),1},xk(j,1)];
            temp_active_track{end,2} =...
                [active_track{row3(j),2},xk(j,2)];
            temp_active_track{end,3} =...
                [active_track{row3(j),3},vk(j,1)];
            temp_active_track{end,4} =...
                [active_track{row3(j),4},vk(j,2)];
            temp_active_track{end,5} =...
                [active_track{row3(j),5},col3(j,1)];
            temp_active_track{end,6} =...
                [active_track{row3(j),6},i];
        end
    end
    
    % Update database
    dis = ones(size(active_track,1),1) == 1;
    dis(row3) = false;
    dis_track = active_track(dis,:);
    active_track =...
        [new_active_track;temp_active_track;dis_track];
    inactive_track =...
        [inactive_track;exceed_track;new_inactive_track;...
        temp_inactive_track];
    
    % Update free sperms
    x1 = x2;
    x2 = xm;
    
    free_sperm1 = ones(size(x1,1),1) == 0;
    free_sperm1(free_sperm2) = true;
    free_sperm1(free_sperm2(col1(row2))) = false;
    
    free_sperm2 = ones(size(x2,1),1) == 1;
    free_sperm2(col3) = false;
    free_sperm2(col2) = false;
    
end

track = [active_track;inactive_track];

save(['Data/', num2str(ID),'/data.mat'],'data')

end

