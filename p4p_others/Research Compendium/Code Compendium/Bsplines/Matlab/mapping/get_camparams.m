function [IntrinsicMatrix, LensDiostortionParams, RotationMatrix, TranslationMatrix] = get_camparams(nCameras, camSequence, filepath)
%     get camera parameters from h5 file
%     
%     Arguments:
%         nCaeras {int} -- number of cameras
%         camSequence {array} -- camera numbers in sequence
%         filepath {string} -- h5 file path and name
% 
%     Returns:
%         cell -- Intrinsic camera matrix of all cameras
%         cell -- LensDistortion for each camera
%         cell -- Rotation matrix of each camera relative to the first
%         cell -- Translation vector of each camera relative to the first
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % initialise output cells
    IntrinsicMatrix = cell(1, nCameras);
    LensDiostortionParams = cell(1, nCameras);
    RotationMatrix = cell(1, nCameras);
    TranslationMatrix = cell(1, nCameras);

    % for each camera read parameters from h5 file to corresponding cell
    for camNum = 1:nCameras
        label = sprintf('/Intrinsic Matrix for Camera: %d', camSequence(camNum));
        IntrinsicMatrix{camNum} = h5read(filepath, label);

        label = sprintf('/Lens Distortion Coefficients for Camera: %d', camSequence(camNum));
        LensDiostortionParams{camNum} = h5read(filepath, label);

        label = sprintf('/Rotation Matrix for Camera: %d', camSequence(camNum));
        RotationMatrix{camNum} = h5read(filepath, label);
        
        label = sprintf('/Translation Matrix for Camera: %d', camSequence(camNum));
        TranslationMatrix{camNum} = h5read(filepath, label);
    end
end
