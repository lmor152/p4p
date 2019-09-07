nCameras = 2;
camSequence = [1, 2];
CPfilename = 'take3_OPTIMISED-PARAMETERS.h5';
%filepath = sprintf(strcat(imageDir,'/Camera Parameters/%s.h5'), CPfilename);
filepath = CPfilename;

IntrinsicMatrix = cell(1, nCameras);
LensDiostortionParams = cell(1, nCameras);
RotationMatrix = cell(1, nCameras);
TranslationMatrix = cell(1, nCameras);

% CamNum is the index for CameraNumbers 
% i.e. if CameraNumbers = [6, 4, 1, 3, 2] then CamNum = 1 is for camera 6

for camNum = 1:nCameras
    label = sprintf('/Intrinsic Matrix for Camera: %d', camSequence(camNum));
    IntrinsicMatrix{camNum} = h5read(filepath, label);
    dlmwrite(sprintf('IntrincsicCam%d.csv',camNum), IntrinsicMatrix{camNum})
    
    label = sprintf('/Lens Distortion Coefficients for Camera: %d', camSequence(camNum));
    LensDiostortionParams{camNum} = h5read(filepath, label);
    dlmwrite(sprintf('LensDiostortionCam%d.csv',camNum), LensDiostortionParams{camNum})
    
    label = sprintf('/Rotation Matrix for Camera: %d', camSequence(camNum));
    RotationMatrix{camNum} = h5read(filepath, label);
    dlmwrite(sprintf('RotationCam%d.csv',camNum), RotationMatrix{camNum})
    
    label = sprintf('/Translation Matrix for Camera: %d', camSequence(camNum));
    TranslationMatrix{camNum} = h5read(filepath, label);
    dlmwrite(sprintf('Translation%d.csv',camNum), TranslationMatrix{camNum})

end