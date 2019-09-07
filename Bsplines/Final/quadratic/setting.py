import numpy as np
import BAquad as BA
from sklearn.decomposition import PCA
from scipy import stats
from plyfile import PlyData

def init(solve = False, u = 20, v = 20, eps = 1e-6, d=3, xgridFile = 'xgrid.csv', ygridFile = 'ygrid.csv', PhiFile = "Phi.csv", ptcFileName = 'pc.ply'):

    global xyrange, Phi_control_nonuni, xgrid, ygrid, points

    mesh = PlyData.read(ptcFileName)
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
    xgrid = genfromtxt(xgridFile, delimiter=',')
    ygrid = genfromtxt(ygridFile, delimiter=',')

    if solve:
        Phi_control_nonuni = BA.BA_control_nonuni(d, points, xgrid, ygrid)
        np.savetxt(PhiFile, Phi_control_nonuni, delimiter=",")

    Phi_control_nonuni = genfromtxt(PhiFile, delimiter=',')

    xyrange = [min(points[:,0]), min(points[:,1])]

def init_est(points):
    global est
    est = points[:, 0:2]
