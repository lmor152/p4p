import numpy as np
from numpy import genfromtxt
import BAquad as BA
import setting
from optimisation import *
from plyfile import PlyData, PlyElement

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

ptex = genfromtxt('../camparams/forehead/texturemap', delimiter=',')
xypoints = ptex[:,0:2]
texture = ptex[:,2]

worldpoints = np.c_[xypoints, np.zeros(len(xypoints))]
origin = [np.dot(np.array([0,0,0]) - centroid, V[0,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[1,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[2,:])]

from numpy import genfromtxt
newPhi = genfromtxt('NLPhi.csv', delimiter = ',') 
#res = o.nonlinear_errors(newPhi, points, xgrid, ygrid, xyrange, d)

proj = texture_coords(newPhi, xypoints, origin, xypoints, xgrid, ygrid, xyrange, d)
texpoints = np.array(proj[:,0].tolist())

xlogic = (texpoints[:,0] >= min(points[:,0])) & (texpoints[:,0] <= max(points[:,0]))
ylogic = (texpoints[:,1] >= min(points[:,1])) & (texpoints[:,1] <= max(points[:,1]))
cleanpoints = texpoints[xlogic & ylogic]
cleantext = texture[xlogic & ylogic]

texpointZ = vevaluatePoint_Control_nonuni(d, cleanpoints[:,0], cleanpoints[:,1], xgrid, ygrid, xyrange, newPhi)
texpoints3d = np.c_[cleanpoints, texpointZ]

world_coord = np.zeros(np.shape(texpoints3d))
for ind,i in enumerate(texpoints3d):
    world_coord[ind] = centroid + V[0,:]*i[0] + V[1,:]*i[1] + V[2,:]*i[2]

#vertices = np.array(list(zip(world_coord[:,0], world_coord[:,1], world_coord[:,2])), dtype = [('x', 'f4'), ('y', 'f4'), ('z', 'f4')])
#el = PlyElement.describe(vertices, 'world_coord') 
#PlyData([el], text = True).write('texturesurf.ply')
np.savetxt('texturesurf.csv', world_coord, delimiter=',')
np.savetxt('cleantex.csv', cleantext, delimiter=',')
