function [IntrinsicMatrix, LensDiostortionParams, RotationMatrix, TranslationMatrix] = get_camparams(nCameras, camSequence, CPfilename)
    %filepath = sprintf(strcat(imageDir,'/Camera Parameters/%s.h5'), CPfilename);
    filepath = CPfilename;

    IntrinsicMatrix = cell(1, nCameras);
    LensDiostortionParams = cell(1, nCameras);
    RotationMatrix = cell(1, nCameras);
    TranslationMatrix = cell(1, nCameras);

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
