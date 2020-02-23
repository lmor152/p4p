import numpy as np
import BAquad as BA
from sklearn.decomposition import PCA
from scipy import stats
from plyfile import PlyData

def init(solve = False, u = 20, v = 20, eps = 1e-6, d=3, xgridFile = 'xgrid.csv', ygridFile = 'ygrid.csv', PhiFile = "Phi.csv", ptcFileName = 'pc.ply'):
    
    # declare global variables
    global xyrange, Phi_control_nonuni, xgrid, ygrid, points, pca, plane, V, centroid
    # read in point cloud
    mesh = PlyData.read(ptcFileName)
    x = mesh.elements[0]['x']
    y = mesh.elements[0]['y']
    z = mesh.elements[0]['z']
    points = np.c_[x, y, z]
    centroid = [np.mean(x), np.mean(y), np.mean(z)]
    # get PCAP and transformed points
    pca = PCA(n_components=3)
    pca.fit(points)
    pca_score = pca.explained_variance_ratio_
    V = pca.components_
    tpts = pca.transform(points)
    tx = tpts[:, 0]
    ty = tpts[:, 1]
    tz = tpts[:, 2]
    points = np.c_[tx,ty,tz]
    dz = np.dot(centroid, V[2,:])
    plane = np.append(V[2,:], [dz])
    # get knot grid
    from numpy import genfromtxt
    xgrid = genfromtxt(xgridFile, delimiter=',')
    ygrid = genfromtxt(ygridFile, delimiter=',')
    
    # get control point grid
    if solve:
        Phi_control_nonuni = BA.BA_control_nonuni(d, points, xgrid, ygrid)
        np.savetxt(PhiFile, Phi_control_nonuni, delimiter=",")
        
    Phi_control_nonuni = genfromtxt(PhiFile, delimiter=',')

    xyrange = [min(points[:,0]), min(points[:,1])]

def init_est(points):
    # declare global variable
    global est
    # assign variable
    est = points[:, 0:2]
