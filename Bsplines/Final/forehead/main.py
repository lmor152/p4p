import numpy as np
from numpy import genfromtxt
import BAquad as BA
import setting
from optimisation import *
from plyfile import PlyData, PlyElement
import cv2
import texturemapping as t

eps = 1e-6
solve = False
u = 10
v = 10
d = 3
ptcFileName = 'pc_9.ply'
xgridFile = 'xgrid_95.csv'
ygridFile = 'ygrid_95.csv'
PhiFile = 'Phi_95.csv'

setting.init(solve, u, v, eps, d, xgridFile, ygridFile, PhiFile, ptcFileName)
Phi = setting.Phi_control_nonuni
points = setting.points
xgrid = setting.xgrid
ygrid = setting.ygrid
xyrange = setting.xyrange
centroid = setting.centroid
V = setting.V
plane = setting.plane

from numpy import genfromtxt
fx = genfromtxt('../camparams/IntrincsicCam1.csv', delimiter=',')
F = fx[0,0]
cx = fx[0,2]
cy = fx[1,2]
asp = F/fx[1,1]

img = cv2.imread('../camparams/L.bmp')
tex, points =  t.projection(img, plane, V[0,:], V[1,:], centroid, F, cx, cy, asp)

xmin, ymin = xyrange
xmax = max(xgrid) + xmin
ymax = max(ygrid) + ymin

xlogic = (points[:,0] >= xmin) & (points[:,0] <= xmax)
ylogic = (points[:,0] >= ymin) & (points[:,0] <= ymax)

xypoints = points[xlogic & ylogic]
texture = tex[xlogic & ylogic]

worldpoints = np.c_[xypoints, np.zeros(len(xypoints))]
origin = [np.dot(np.array([0,0,0]) - centroid, V[0,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[1,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[2,:])]

from numpy import genfromtxt
newPhi = genfromtxt('NLPhi.csv', delimiter = ',') 

proj = texture_coords(newPhi, xypoints, origin, xypoints, xgrid, ygrid, xyrange, d)
texpoints = np.array(proj[:,0].tolist())

xlogic = (texpoints[:,0] >= xmin) & (texpoints[:,0] <= xmax)
ylogic = (texpoints[:,1] >= ymin) & (texpoints[:,1] <= ymax)
cleanpoints = texpoints[xlogic & ylogic]
cleantext = texture[xlogic & ylogic]

texpointZ = vevaluatePoint_Control_nonuni(d, cleanpoints[:,0], cleanpoints[:,1], xgrid, ygrid, xyrange, newPhi)
texpoints3d = np.c_[cleanpoints, texpointZ]

world_coord = np.zeros(np.shape(texpoints3d))
for ind,i in enumerate(texpoints3d):
    world_coord[ind] = centroid + V[0,:]*i[0] + V[1,:]*i[1] + V[2,:]*i[2]

#np.savetxt('texturesurf.csv', world_coord, delimiter=',')
#np.savetxt('cleantex.csv', cleantext, delimiter=',')

Rcam2 = genfromtxt('../camparams/RotationCam2.csv', delimiter= ',')
Tcam2 = genfromtxt('../camparams/Translation2.csv', delimiter= ',')

from scipy.spatial.transform import Rotation as R
r = R.from_rotvec(Rcam2)
rotaionMatrix = r.as_dcm().T
fmatrix = np.matmul(fx, np.matmul(np.c_[np.identity(3), np.zeros(3)], np.vstack([np.c_[rotaionMatrix, Tcam2], [0,0,0,1]])))

ptc1 = np.c_[world_coord, np.ones(len(world_coord))]
img = np.matmul(fmatrix, ptc1.T)
image = img[0:2,:]
image[0,:] = np.divide(img[0,:], img[2,:])
image[1,:] = np.divide(img[1,:], img[2,:])
image[1,:] = image[1,:] * asp

nonuniform = image.T
umin = int(np.floor(min(nonuniform[:,0])))
umax = int(np.floor(max(nonuniform[:,0])))
vmin = int(np.floor(min(nonuniform[:,1])))
vmax = int(np.floor(max(nonuniform[:,1])))

A, B = np.meshgrid(range(umin, umax + 1), range(vmin, vmax+1))
Y = np.c_[A.flatten(), B.flatten()]

from sklearn.neighbors import NearestNeighbors
knn = NearestNeighbors(n_neighbors=5)
knn.fit(nonuniform)
D, Ind = knn.kneighbors(Y)

newtext = np.zeros(len(Ind))
for i in range(0, len(Ind)):
    newtext[i] = np.dot(D[i,:], cleantext[Ind[i,:]]) / sum(D[i,:])

IMG = np.zeros((len(range(vmin, vmax + 1)), len(range(umin, umax+1))))
for i in range(0,len(Y)):
    IMG[Y[i,1] - vmin, Y[i,0] - umin] = newtext[i]

IMG = IMG.astype(np.uint8)

R = cv2.imread('../camparams/R.bmp')
from skimage.measure import compare_ssim
compare_ssim(IMG, R[vmin:vmax+1, umin:umax+1, 1])
