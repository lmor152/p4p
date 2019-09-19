import numpy as np
from numpy import genfromtxt
import BAquad as BA
import setting
from optimisation import *

eps = 1e-6
solve = True
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
centroid = setting.centroid
V = setting.V

ptex = genfromtxt('../camparams/texturemap', delimiter=',')
xypoints = ptex[:,0:2]
texture = ptex[:,2]

worldpoints = np.c_[xypoints, np.zeros(len(xypoints))]
origin = [np.dot(np.array([0,0,0]) - centroid, V[0,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[1,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[2,:])]

#texture_obj(xypoints[0,:], origin, xypoints[0,:], xgrid, ygrid, xyrange, Phi, d)
#te = texture_coords(Phi, xypoints, origin, xypoints, xgrid, ygrid, xyrange, d)
#planarpoints = np.array(te[:,0].tolist())
from numpy import genfromtxt
planarpoints = genfromtxt('planepoints.csv', delimiter=',')

xlogic = (planarpoints[:,0] >= min(points[:,0])) & (planarpoints[:,0] <= max(points[:,0]))
ylogic = (planarpoints[:,1] >= min(points[:,1])) & (planarpoints[:,1] <= max(points[:,1]))

cleanpoints = planarpoints[xlogic & ylogic]
Z = BA.vevaluatePoint_Control_nonuni(d, cleanpoints[:,0], cleanpoints[:,1], xgrid, ygrid, xyrange, Phi)
surfacepoints = np.c_[cleanpoints, Z]
world_coord = np.zeros(np.shape(surfacepoints))
for ind,i in enumerate(surfacepoints):
    world_coord[ind] = centroid + V[0,:]*i[0] + V[1,:]*i[1] + V[2,:]*i[2]

np.savetxt('surface_3d.csv', world_coord, delimiter=',')

if plot:
    tx = points[:,0]
    ty = points[:,1]

    X = np.arange(np.ceil(min(tx)),np.floor(max(tx)), 1)
    Y = np.arange(np.ceil(min(ty)),np.floor(max(ty)), 1)

    X,Y = np.meshgrid(X,Y)

    Z = BA.evaluateSurface_Control_nonuni(d, X, Y, xgrid, ygrid, xyrange, Phi)

    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d import Axes3D

    # Create figure.
    fig = plt.figure()
    ax = fig.gca(projection = '3d')
    surf = ax.plot_surface(X, Y, Z)

    max_range = np.array([X.max()-X.min(), Y.max()-Y.min(), Z.max()-Z.min()]).max() / 2.0

    mid_x = (X.max()+X.min()) * 0.5
    mid_y = (Y.max()+Y.min()) * 0.5
    mid_z = (Z.max()+Z.min()) * 0.5
    ax.set_xlim(mid_x - max_range, mid_x + max_range)
    ax.set_ylim(mid_y - max_range, mid_y + max_range)
    ax.set_zlim(mid_z - max_range, mid_z + max_range)

    #plt.show(block=True)
    # Set viewpoint.
    ax.azim = 130
    ax.elev = -120

    #fig.savefig('face.png')
    plt.show(block=True)
