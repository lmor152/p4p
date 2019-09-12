import numpy as np
from numpy import genfromtxt
import BAquad as BA
import setting
from optimisation import *

eps = 1e-6
solve = False
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

#texture_obj(xypoints[0,:], origin, xgrid, ygrid, xyrange, Phi, d)



#Z = BA.vevaluatePoint_Control_nonuni(d, xypoints[:,0], xypoints[:,1], xgrid, ygrid, xyrange, Phi)
#line = origin - origin*t