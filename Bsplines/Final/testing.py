from optimisation import *
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
u = 20
v = 20

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
points = np.c_[tx,ty,tz]

from numpy import genfromtxt
xgrid = genfromtxt('xgrid.csv', delimiter=',')
ygrid = genfromtxt('ygrid.csv', delimiter=',')

if solve:
    Phi_control_nonuni = BA.BA_control_nonuni(points, xgrid, ygrid)
    np.savetxt("Phi2.csv", Phi_control_nonuni, delimiter=",")

Phi_control_nonuni = genfromtxt('Phi2.csv', delimiter=',')

xyrange = [min(points[:,0]), min(points[:,1])]

est = points[:, 0:2]
dPhi = lattice_df(est, points, xgrid, ygrid, xyrange, Phi_control_nonuni)