import numpy as np
from bisect import *

def Basis(k,t):
    assert(0 <= t and t < 1) 
    assert(k<=3)
    basis = {
    0: (1 - t)**3/6,
    1: (t * t * (3 * t - 6) + 4) / 6,
    2: (t * (t * (-3 * t + 3) + 3) + 1) / 6,
    3: t ** 3 / 6
    }
    return basis[k]

def dBasis(k,t):
    assert(0 <= t and t < 1) 
    assert(k<=3) 
    dBasis = {
    0: (-(1 - t)**2)/2,
    1: (t * (3 * t - 4))/2,
    2: (t * (2 - 3 * t) + 1)/2,
    3: (t**2) / 2
    }
    return dBasis[k]  

def vBasis(k,t):
    vBasis = np.vectorize(Basis)
    return vBasis(k,t)

def vdBasis(k,t):
    vdBasis = np.vectorize(dBasis)
    return vdBasis(k,t)

def vectorw(k, l, s, t):
    vBasis = np.vectorize(Basis)
    return vBasis(k,s) * vBasis(l,t)

def vectorsum_w_ab2(s,t):
    A,B = np.meshgrid(range(0,4),range(0,4))
    return np.sum(vectorw(A,B,s,t)**2)

def find_gt(a, x):
    i = bisect_right(a, x)
    if i <= 0:
        return a[0], a[0] - (a[1] - a[0]), i - 1
    elif i != len(a):
        return a[i], a[i-1],  i - 1 
    elif i >= len(a):
        return a[i-1] + (a[i-1] - a[i-2]), a[i-1], i - 1
    raise ValueError

def vfind_gt(a, x):
    ls = []
    for i in x:
        ub, lb, ind = find_gt(a,i)
        d = (i - lb) / (ub - lb)
        r = [ub, lb, ind, d]
        ls.append(r)
    return np.array(ls)

def BA_control_nonuni(points, xgrid, ygrid):
       
    minM = min(points[:,0])
    minN = min(points[:,1])

    u = len(xgrid)
    v = len(ygrid)

    delta = np.zeros((u+2, v+2))
    omg = np.zeros((u+2, v+2))
    PHI = np.zeros((u+2, v+2))

    for p in points:

        exmax, exmin, i = find_gt(xgrid, p[0] - minM)
        eymax, eymin, j = find_gt(ygrid, p[1] - minN) 

        s = (p[0] - minM - exmin)/(exmax - exmin)
        t = (p[1] - minN - eymin)/(eymax - eymin)

        sum_wab2 = vectorsum_w_ab2(s, t)

        for k in range(0, 4):
            for l in range(0, 4):
                w_kl = vectorw(k, l, s, t)
                PHI_kl = w_kl * p[2]/sum_wab2
                delta[i+k, j+l] = delta[i+k, j+l] + PHI_kl * w_kl**2
                omg[i+k, j+l] = omg[i+k, j+l] + w_kl**2
        
    for i in range(0,u+2):
        for j in range(0,v+2):
            if omg[i, j] != 0:
                PHI[i, j] = delta[i, j]/omg[i, j]
        
    return PHI

def vevaluatePoint_Control_nonuni(x, y, xgrid, ygrid, xyrange, Phi):   
    minM = xyrange[0]
    minN = xyrange[1]
    xls = vfind_gt(xgrid, x - minM)
    yls = vfind_gt(ygrid, y - minN)

    f = np.zeros(np.shape(x))
    for k in range(0,4):
        for l in range(0,4):
            f = f + vectorw(k, l, xls[:,3], yls[:,3])*Phi[xls[:,2].astype(int)+k,yls[:,2].astype(int)+l]  
    return f   

def vectordw(k, l, s, t):
    vBasis = np.vectorize(Basis)
    vdBasis = np.vectorize(dBasis)
    return vdBasis(k,s) * vBasis(l,t) + vBasis(k,s) * vdBasis(l,t)

def evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, xyrange, Phi):
    Z = np.zeros(np.shape(X))
    for i in range(0, np.shape(X)[0]):
        Z[i,:] = vevaluatePoint_Control_nonuni(X[i,:], Y[i,:], xgrid, ygrid, xyrange, Phi)
    return Z

def avgError(points, xgrid, ygrid, Phi):
    xyrange = [min(points[:,0]), min(points[:,1])]
    pred = vevaluatePoint_Control_nonuni(points[:,0], points[:,1], xgrid, ygrid, xyrange, Phi)
    error = pred - points[:,2]
    RMSE = np.sqrt(np.mean(error**2))
    return RMSE

