function [ r, c ] = modify_RW( row, col )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if size(row,2) > 1
    r = row';
else
    r = row;
end
if size(col,2) > 1
    c = col';
else
    c = col;
end
end

