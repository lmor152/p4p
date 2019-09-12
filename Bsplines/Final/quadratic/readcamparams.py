import cv2
from numpy import genfromtxt
import numpy as np

dir = '../camparams/'
cams = [1, 2]

Rotation = []
Intrinsic = []
Lens = []
Translation = []

for i in cams:
    Rotation.append(genfromtxt(dir + "RotationCam" + str(i) + ".csv", delimiter=','))
    Intrinsic.append(genfromtxt(dir + "IntrincsicCam" + str(i) + ".csv", delimiter=','))
    Lens.append(genfromtxt(dir + "LensDiostortionCam" + str(i) + ".csv", delimiter=','))
    Translation.append(genfromtxt(dir + "Translation" + str(i) + ".csv", delimiter=','))

camImage = []
camImage.append(cv2.imread(dir + 'L.bmp'))
camImage.append(cv2.imread(dir + 'R.bmp'))

# undistort images
camImage[0] = cv2.undistort(camImage[0], Intrinsic[0], Lens[0])
camImage[1] = cv2.undistort(camImage[1], Intrinsic[1], Lens[1])

S = cv2.stereoRectify(Intrinsic[0],Lens[0],Intrinsic[1],Lens[1], np.shape(camImage[0])[0:2],  Rotation[1].T, Translation[1].T)

R2 = S[1]
Q = S[4]

np.savetxt(dir + 'S.R2', R2, delimiter=",")
np.savetxt(dir + 'S.Q', Q, delimiter=",")
cv2.imwrite(dir + 'Undistort1.png', camImage[0])
cv2.imwrite(dir + 'Undistort2.png', camImage[1])
