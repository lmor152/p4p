import numpy as np
import BAquad as BA
import optimisation as o
import setting

eps = 1e-6
definegrid = False
solve = False
plot = False
u = 20
v = 20
d = 2
ptcFileName = 'pc_9.ply'
xgridFile = 'xgrid_9.csv'
ygridFile = 'ygrid_9.csv'
PhiFile = 'Phi_9.csv'

setting.init(solve, u, v, eps, d, xgridFile, ygridFile, PhiFile, ptcFileName)
Phi = setting.Phi_control_nonuni
points = setting.points
xgrid = setting.xgrid
ygrid = setting.ygrid
xyrange = setting.xyrange
pca = setting.pca

xgridplot = xgrid + xyrange[0]
xgridplot[-1] = xgridplot[-1] - eps
ygridplot = ygrid + xyrange[1]
ygridplot[-1] = ygridplot[-1] - eps

Xcontrol, Ycontrol = np.meshgrid(xgridplot, ygridplot)
Zcontrol = BA.evaluateSurface_Control_nonuni(d, Xcontrol, Ycontrol, xgrid, ygrid, xyrange, Phi)
tpoints = pca.inverse_transform(np.c_[Xcontrol.flatten(), Ycontrol.flatten(), Zcontrol.flatten()])
'''
np.savetxt('3dcontrolpoints.csv', tpoints, delimiter=',')
import readcamparams

import matlab.engine
eng = matlab.engine.start_matlab()
eng.addpath('../camparams/', nargout=0)
eng.rectify(nargout=0)
eng.close()

from numpy import genfromtxt
out1 = genfromtxt('out1.csv', delimiter=',')
out2 = genfromtxt('out2.csv', delimiter=',')

grid = np.indices((u, v)) + 1
xout1 = out1[:,0].reshape(u,v)
yout1 = out1[:,1].reshape(u,v)
quad = []
for i in range(1,u):
    for j in range(1,v):
        indtl = (np.mod(grid[0], u) == i%u) & (np.mod(grid[1], v) == j%v) 
        indbl = (np.mod(grid[0], u) == (i+1)%u) & (np.mod(grid[1], v) == j%v)
        indtr = (np.mod(grid[0], u) == i%u) & (np.mod(grid[1], v) == (j+1)%v)
        indbr = (np.mod(grid[0], u) == (i+1)%u) & (np.mod(grid[1], v) == (j+1)%v)
        tl = [xout1[indtl][0], yout1[indtl][0]]
        tr = [xout1[indtr][0], yout1[indtr][0]]
        bl = [xout1[indbl][0], yout1[indbl][0]]
        br = [xout1[indbr][0], yout1[indbr][0]]
        quad.append([tl,tr,bl,br])

import matplotlib.pyplot as plt
import cv2
image = cv2.imread('../camparams/L.bmp')

mask = np.zeros((image.shape[0], image.shape[1]))
cv2.fillConvexPoly(mask, np.array(quad[0], dtype=np.int32), 255)
mask = mask.astype(np.bool)

out = np.zeros_like(image[:,:,0])
out[mask] = image[:,:,0][mask]

implot = plt.imshow(out)
#plt.scatter(out1[:,0], out1[:,1], s=2, color = 'red')
plt.show()
'''

if plot:
    
    Xplot = tpoints[:,0].reshape(np.shape(Xcontrol))
    Yplot = tpoints[:,1].reshape(np.shape(Ycontrol))
    Zplot = tpoints[:,2].reshape(np.shape(Zcontrol))
    
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

    # Create figure.
fig = plt.figure()
ax = fig.gca(projection = '3d')
    scatter = ax.scatter3D(Xplot, Yplot, Zplot)

    max_range = np.array([Xplot.max()-Xplot.min(), Yplot.max()-Yplot.min(), Zplot.max()-Zplot.min()]).max() / 2.0

    mid_x = (Xplot.max()+Xplot.min()) * 0.5
    mid_y = (Yplot.max()+Yplot.min()) * 0.5
    mid_z = (Zplot.max()+Zplot.min()) * 0.5
    ax.set_xlim(mid_x - max_range, mid_x + max_range)
    ax.set_ylim(mid_y - max_range, mid_y + max_range)
    ax.set_zlim(mid_z - max_range, mid_z + max_range)

    #plt.show(block=True)
    # Set viewpoint.
    ax.azim = 130
    ax.elev = -120

    #fig.savefig('face.png')
    plt.show(block=True)
