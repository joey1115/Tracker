function  x  = getData( ID, frame )
%   getData, obtain the coordinate of sperms depend on using image
%   processing
%   Input:
%       frame
%   Output:
%       coordinate of sperms
% A = imread(['Data/',num2str(ID),'/images/edited/',num2str(frame),'.jpg']);
% A1 = rgb2gray(A);
% A2 = medfilt2(A1,[3,3]);
% A3 = imadjust(A2,[],[],0.5);
% A3 = uint8(A3);
% Im2 = A3<150;
% Im2 = imclearborder(Im2); 
% B = regionprops(Im2,'Area','Eccentricity','Solidity','Centroid');
% x = [];
% for i = 1:size(B,1)
%     if B(i).Eccentricity > 0.6 && B(i).Solidity > 0.9 && B(i).Area > 3
%         x(end+1,1:2) = B(i).Centroid;
%     end
% end
% 
% x = [ones(0,2);x];
load(fullfile(pwd,'Data',num2str(ID),'Centriod.mat'))
x = double(centroid_final{frame,1});
% x = [x(:,2), x(:,1)];

end