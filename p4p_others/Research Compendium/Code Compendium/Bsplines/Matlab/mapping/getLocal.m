function [x, y] = getLocal(world, v1, v2, centroid)
%     get local coordinate of point on PCAP 
%     
%     Arguments:
%         world {array} -- world point (x, y, z) 
%         v1 {array} -- first vector that defines PCAP
%         v2 {array} -- second vector that defines PCAP
%         centroid {array} -- centroid of PCAP (x, y, z)
% 
%     Returns:
%         float -- x
%         float -- y
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get transformed (x, y)
    x = dot(world - centroid, v1);
    y = dot(world - centroid, v2);
end
