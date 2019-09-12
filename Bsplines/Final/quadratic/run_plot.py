import numpy as np
import BAquad as BA
import optimisation as o
import setting
from scipy.optimize import scipy.optimize.minimize

eps = 1e-6
definegrid = False
solve = False
plot = False
u = 5
v = 5
d = 2
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

#res = o.nonlinear_errors(Phi, points, xgrid, ygrid, xyrange, d)
#665761.8452114458
result = scipy.optimize.minimize(o.nonlinear_errors, Phi.flatten(), args = (points, xgrid, ygrid, xyrange, d), options = {'maxiter':1, 'disp':True})

maxit = 10
field = o.field_nonlinear(Phi, points, xgrid, ygrid, xyrange, d, maxit)
resx = field.x.reshape(len(xgrid) + 2, len(ygrid) + 2)
np.savetxt("NLPhi.csv", resx, delimiter=",")
print(field.fun)
print(field.message)

from numpy import genfromtxt
newPhi = genfromtxt('NLPhiFinal.csv', delimiter=',')

if plot:
    tx = points[:,0]
    ty = points[:,1]

    X = np.arange(np.ceil(min(tx)),np.floor(max(tx)), 1)
    Y = np.arange(np.ceil(min(ty)),np.floor(max(ty)), 1)

    X,Y = np.meshgrid(X,Y)

    Z = BA.evaluateSurface_Control_nonuni(d, X, Y, xgrid, ygrid, xyrange, newPhi)

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
