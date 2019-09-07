import numpy as np
import BA

from sklearn.decomposition import PCA
from mpl_toolkits.mplot3d import Axes3D

import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

from plyfile import PlyData

eps = 1e-6

mesh = PlyData.read('pc.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]

r = mesh.elements[0]['red']
g = mesh.elements[0]['blue']
b = mesh.elements[0]['green']

colors = np.c_[r, g, b]

pca = PCA(n_components=3)

pca.fit(points)
pca_score = pca.explained_variance_ratio_
V = pca.components_

tpts = pca.transform(points)
tx = tpts[:, 0]
ty = tpts[:, 1]
tz = tpts[:, 2]

points = np.c_[tx,ty,tz]

u = 20
v = 20

minM = min(points[:,0])
minN = min(points[:,1])

gridm = max(points[:,0]) - minM
gridn = max(points[:,1]) - minN

m = gridm/(u-1)
n = gridn/(v-1)

xgrid = np.arange(min(tx) - eps, max(tx) + m + eps, m) - minM
ygrid = np.arange(min(ty) - eps, max(ty) + n + eps, n) - minN

#Phi = BA.BA(points)
Phi_control_nonuni = BA.BA_control_nonuni(points, xgrid, ygrid)
#Phi_control = BA.BA_control_(points, u, v)

X = np.arange(np.ceil(min(tx)),np.floor(max(tx)), 1)
Y = np.arange(np.ceil(min(ty)),np.floor(max(ty)), 1)

X,Y = np.meshgrid(X,Y)

#Z = BA.evaluateSurface(X, Y, points, Phi)
#Z = BA.evaluateSurface_Control(X, Y, u, v, points, Phi_control)

Z = BA.evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, points, Phi_control_nonuni)

import matplotlib.pyplot as plt
fig = plt.figure(1, figsize=(4, 3))
plt.clf()
ax = Axes3D(fig, rect=[0, 0, .95, 1], elev=90, azim=0)
ax.plot_surface(X, Y, Z)
plt.show()