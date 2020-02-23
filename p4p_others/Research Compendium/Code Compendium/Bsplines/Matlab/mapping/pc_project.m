function [x, y, z] = pc_project(world, v1, v2, v3, centroid)
%     transform world point to PCAP coordinates
%     
%     Arguments:
%         world {array} -- world point (x, y, z) 
%         v1 {array} -- first vector that defines PCAP
%         v2 {array} -- second vector that defines PCAP
%         v3 {array} -- normal vector to PCAP
%         centroid {array} -- centroid of PCAP (x, y, z)
% 
%     Returns:
%         float -- x
%         float -- y
%         float -- z
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % get transformed (x, y, z)
    x = dot(world - centroid, v1);
    y = dot(world - centroid, v2);
    z = dot(world - centroid, v3);
end
