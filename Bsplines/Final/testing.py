from optimisation import *
import numpy as np
import BAtest as BA
from sklearn.decomposition import PCA

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from scipy import stats

from plyfile import PlyData
from optimisation import *
import scipy.optimize
import multiprocessing as mp

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

def lattice_df(Phi, points, xgrid, ygrid, xyrange):
    Phi = Phi.reshape(len(xgrid) + 2, len(ygrid) + 2)
    minM, minN = xyrange
    dPhi = np.zeros(np.shape(Phi))
    global est
    xls = BA.vfind_gt(xgrid, est[:,0] - minM)
    yls = BA.vfind_gt(ygrid, est[:,1] - minN)
    evals = BA.vevaluatePoint_Control_nonuni(est[:,0], est[:,1], xgrid, ygrid, xyrange, Phi)
    error = points[:,2] - evals
    for q in range(0, len(error)):
        Bs = BA.vBasis(range(0,4), xls[q,3])
        Bt = BA.vBasis(range(0,4), yls[q,3])
        delPhi = -2 * np.outer(Bs, Bt) * error[q]
        i = int(xls[q,2])
        j = int(yls[q,2])
        dPhi[i:i+4, j:j+4] = delPhi + dPhi[i:i+4, j:j+4]
    return dPhi.flatten()

def mp_nonlinearOptim(e, p, xgrid, ygrid, xyrange, Phi):
    res = scipy.optimize.minimize(obj, e, args = (p, xgrid, ygrid, xyrange, Phi))
    return res.x, res.fun   

def nonlinear_errors(Phi, points, xgrid, ygrid, xyrange):
    Phi = Phi.reshape(len(xgrid) + 2, len(ygrid) + 2)
    pool = mp.Pool(mp.cpu_count())
    global est
    result = pool.starmap(mp_nonlinearOptim, [(e, p, xgrid, ygrid, xyrange, Phi) for (e,p) in zip(est, points)])
    result = np.array(result)
    est = result[:,0]
    est = np.array(est.tolist())
    pool.close()
    return np.sum(error)

def field_nonlinear(Phi, points, xgrid, ygrid, xyrange):
    result = scipy.optimize.minimize(nonlinear_errors, Phi.flatten(), args = (points, xgrid, ygrid, xyrange), jac = lattice_df)
    return result 



res = field_nonlinear(Phi_control_nonuni, points, xgrid, ygrid, xyrange)
np.savetxt("NLPhi.csv", res.x, delimiter=",")
print(res)
