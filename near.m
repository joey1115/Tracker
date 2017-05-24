function [ tab ] = near( x1,x2,lim )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
m = size(x1,1);
n = size(x2,1);
x1tmp = repmat(x1(:,1),1,n);
x2tmp = repmat(x2(:,1)',m,1);
xtmp = x1tmp - x2tmp;
y1tmp = repmat(x1(:,2),1,n);
y2tmp = repmat(x2(:,2)',m,1);
ytmp = y1tmp - y2tmp;
dis = sqrt(xtmp.^2+ytmp.^2);
tab = ones(m,n) == 1;
if size(lim,1) == 1
    tab(dis>lim(2)) = false;
    tab(dis<lim(1)) = false;
else
    for i = 1:size(lim,1)
        tab(i,dis(i,:)>lim(i,2)) = false;
        tab(i,dis(i,:)<lim(i,1)) = false;
    end
end
end