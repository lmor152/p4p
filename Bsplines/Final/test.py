import numpy as np
import BAtest as BA
from sklearn.decomposition import PCA

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from scipy import stats

from plyfile import PlyData
from optimisation import *

eps = 1e-6
definegrid = False
solve = False
plot = True
u = 20
v = 20

ptcFileName = 'pc_9.ply'
xgridFile = 'xgrid_9.csv'
ygridFile = 'ygrid_9.csv'
PhiFile = 'Phi_9'

mesh = PlyData.read(ptcFileName)
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]

'''
tx = points[:, 0]
ty = points[:, 1]
tz = points[:, 2]
'''

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
    np.savetxt(xgridFile, xgrid, delimiter=",")
    np.savetxt(ygridFile, ygrid, delimiter=",")
   
from numpy import genfromtxt
xgrid = genfromtxt(xgridFile, delimiter=',')
ygrid = genfromtxt(ygridFile, delimiter=',')

if solve:
    Phi_control_nonuni = BA.BA_control_nonuni(points, xgrid, ygrid)
    np.savetxt(PhiFile, Phi_control_nonuni, delimiter=",")

Phi_control_nonuni = genfromtxt(PhiFile, delimiter=',')

xyrange = [min(points[:,0]), min(points[:,1])]

if plot:
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

RMSE, SSE = BA.Error(points, xgrid, ygrid, Phi_control_nonuni)
print(RMSE)
print(SSE)