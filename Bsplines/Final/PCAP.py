from sklearn.decomposition import PCA

from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

from plyfile import PlyData
import numpy as np


mesh = PlyData.read('pc.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]

pca = PCA(n_components=3)

pca.fit(points)
pca_score = pca.explained_variance_ratio_
V = pca.components_

tpts = pca.transform(points)
tx = tpts[:, 0]
ty = tpts[:, 1]
tz = tpts[:, 2]

##### tpts are transformed points

x_pca_axis, y_pca_axis, z_pca_axis = 1000*V.T
x_pca_plane = np.r_[x_pca_axis[:2], - x_pca_axis[1::-1]]
y_pca_plane = np.r_[y_pca_axis[:2], - y_pca_axis[1::-1]]
z_pca_plane = np.r_[z_pca_axis[:2], - z_pca_axis[1::-1]]

x_pca_plane.shape = (2, 2)
y_pca_plane.shape = (2, 2)
z_pca_plane.shape = (2, 2)


fig = plt.figure(1, figsize=(4, 3))
plt.clf()
ax = Axes3D(fig, rect=[0, 0, .95, 1], elev=90, azim=0)
ax.scatter(x[::10], y[::10], z[::10], c = 'r', marker='+')
#ax.scatter(rex[::10], rey[::10], rez[::10], c = 'b', marker='+')
ax.plot_surface(x_pca_plane, y_pca_plane, z_pca_plane)

plt.show(block=True)
