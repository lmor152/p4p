import numpy as np
import BAtest as BA
from sklearn.decomposition import PCA

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from scipy import stats

from plyfile import PlyData
from optimisation import *

eps = 1e-6
definegrid = True
solve = True
u = 20
v = 20

mesh = PlyData.read('pc.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]
#tx = points[:, 0]
#ty = points[:, 1]
#tz = points[:, 2]

pca = PCA(n_components=3)
pca.fit(points)
pca_score = pca.explained_variance_ratio_
V = pca.components_
tpts = pca.transform(points)
tx = tpts[:, 0]
ty = tpts[:, 1]
tz = tpts[:, 2]

points = np.c_[tx,ty,tz]

def onclick(event):
    global ix, iy
    ix, iy = event.xdata, event.ydata
    global xcoords, ycoords
    global u , v
    if (len(xcoords) < u):
        xcoords.append(ix)
        plt.axvline(ix, color = 'k')
        fig.canvas.draw()
    else:
        ycoords.append(iy)
        plt.axhline(iy, color = 'k')
        fig.canvas.draw()
    if (len(xcoords) == u) & (len(ycoords) == v):
        fig.canvas.mpl_disconnect(cid)
        plt.close()
        plt.ioff()
    return

if definegrid:
    plt.ion()
    fig = plt.figure()

    heatmap, xedges, yedges = np.histogram2d(tx, ty, bins=100)
    extent = [xedges[0], xedges[-1], yedges[0], yedges[-1]]

    plt.clf()
    plt.imshow(heatmap, aspect = 'equal', extent=extent, origin='lower', cmap = 'Greens')

    plt.axvline(min(tx), color = 'k')
    plt.axvline(max(tx) + eps, color = 'k')
    plt.axhline(min(ty), color = 'k')
    plt.axhline(max(ty) + eps, color = 'k')

    xcoords = [min(tx), max(tx) + eps] 
    ycoords = [min(ty), max(ty) + eps]

    cid = fig.canvas.mpl_connect('button_press_event', onclick)
    plt.show(block=True)

    xgrid = np.sort(xcoords) - min(tx)
    ygrid = np.sort(ycoords) - min(ty)
    np.savetxt("xgrid.csv", xgrid, delimiter=",")
    np.savetxt("ygrid.csv", ygrid, delimiter=",")
   
from numpy import genfromtxt
xgrid = genfromtxt('xgrid.csv', delimiter=',')
ygrid = genfromtxt('ygrid.csv', delimiter=',')

if solve:
    Phi_control_nonuni = BA.BA_control_nonuni(points, xgrid, ygrid)
    np.savetxt("Phi2.csv", Phi_control_nonuni, delimiter=",")

Phi_control_nonuni = genfromtxt('Phi2.csv', delimiter=',')

xyrange = [min(points[:,0]), min(points[:,1])]

#point = points[145,:]
#scipy.optimize.minimize(obj, point[0:2], args = (point, xgrid, ygrid, xyrange, Phi_control_nonuni))
#scipy.optimize.minimize(obj, point[0:2], args = (point, xgrid, ygrid, xyrange, Phi_control_nonuni), jac = jac)
#newcoords, obj = nonlinearOptim(xgrid, ygrid, points, Phi_control_nonuni)

#import multiprocessing as mp
#pool = mp.Pool(mp.cpu_count())
#result = pool.starmap(mp_nonlinearOptim, [(p, xgrid, ygrid, xyrange, Phi_control_nonuni) for p in points])
#pool.close()

#result = scipy.optimize.minimize(nonlinear_errors, Phi_control_nonuni, args = (points, xgrid, ygrid, xyrange))
est = points[:,0:2]
#xgrid = [xgrid[0] - (xgrid[1] - xgrid[0])] + xgrid.tolist() + [xgrid[-1] + (xgrid[-1] - xgrid[-2])]
#ygrid = [ygrid[0] - (ygrid[1] - ygrid[0])] + ygrid.tolist() + [ygrid[-1] + (ygrid[-1] - ygrid[-2])]

X = np.arange(np.ceil(min(tx)),np.floor(max(tx)), 1)
Y = np.arange(np.ceil(min(ty)),np.floor(max(ty)), 1)

X,Y = np.meshgrid(X,Y)

Z = BA.evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, xyrange, Phi_control_nonuni)
#Z = BA.evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, xyrange, result)

import matplotlib.pyplot as plt
fig = plt.figure(1)

plt.clf()
ax = Axes3D(fig, rect=[0, 0, 1, 1], elev=90, azim=0)
ax.set_xlim3d(min(tx) - eps, max(tx) + eps)
ax.set_ylim3d(min(ty) - eps, max(ty) + eps)
ax.plot_surface(X, Y, Z)
plt.show(block=True)

#rmse = BA.avgError(xyrange, xgrid, ygrid, Phi_control_nonuni)
