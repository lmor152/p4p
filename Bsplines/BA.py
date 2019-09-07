import numpy as np
from bisect import *

def Basis(k,t):
    assert(0 <= t and t < 1) 
    assert(k<=3)
    basis = {0: (1 - t)**3/6,
    1: (t * t * (3 * t - 6) + 4) / 6,
    2: (t * (t * (-3 * t + 3) + 3) + 1) / 6,
    3: t ** 3 / 6
    }
    return basis[k]

def dBasis(k,t):
    assert(0 <= t and t < 1) 
    assert(k<=3) 
    dBasis = {0: (1 - t)**2/2,
    1: t * (3 * t - 4)/2,
    2: (t * (2 - 3 * t) + 1)/2,
    3: t**2/2
    }  

def w(k, l, s, t):
    return Basis(k,s) * Basis(l,t)

def dw(k, l, s, t):
    return Basis(k,s) * dBasis(l,t) + dBasis(k,s) * Basis(l,t)

def vectorw(k, l, s, t):
    vBasis = np.vectorize(Basis)
    return vBasis(k,s) * vBasis(l,t)

def sum_w_ab2(s, t):
    wab2 = 0
    for a in range(0,4):
        for b in range(0,4):
            temp = w(a, b, s, t)
            wab2 = wab2 + temp**2
    
    return wab2

def vecsum_w_ab2(s,t):
    A,B = np.meshgrid(range(0,4),range(0,4))
    return np.sum(vectorw(A,B,s,t)**2)

def BA(points):

    intminM = np.floor(min(points[:,0]))
    intminN = np.floor(min(points[:,1]))

    m = int(np.ceil(max(points[:,0])) - intminM)
    n = int(np.ceil(max(points[:,1])) - intminN)
    
    delta = np.zeros((m+3, n+3))
    omg = np.zeros((m+3, n+3))
    PHI = np.zeros((m+3, n+3))
    
    for p in points:
        i = int(np.floor(p[0]) - intminM)
        j = int(np.floor(p[1]) - intminN)
        s = p[0] - np.floor(p[0])
        t = p[1] - np.floor(p[1])
        sum_wab2 = sum_w_ab2(s, t)
        for k in range(0, 4):
            for l in range(0, 4):
                w_kl = w(k, l, s, t)
                PHI_kl = w_kl * p[2]/sum_wab2
                delta[i+k, j+l] = delta[i+k, j+l] + PHI_kl * w_kl**2
                omg[i+k, j+l] = omg[i+k, j+l] + w_kl**2
        
    for i in range(0,m+3):
        for j in range(0,n+3):
            if omg[i, j] != 0:
                PHI[i, j] = delta[i, j]/omg[i, j]
        
    return PHI

def BA_control(points, u, v):

    minM = min(points[:,0])
    minN = min(points[:,1])

    gridm = max(points[:,0]) - minM
    gridn = max(points[:,1]) - minN

    m = gridm/(u-1)
    n = gridn/(v-1)
    
    delta = np.zeros((u+3, v+3))
    omg = np.zeros((u+3, v+3))
    PHI = np.zeros((u+3, v+3))

    for p in points:

        i = int(np.floor(((p[0] - minM) / m)))
        j = int(np.floor(((p[1] - minN) / n)))

        #s = ((p[0] - minM) / m) - np.floor(((p[0] - minM) / m))
        #t = ((p[1] - minN) / n) - np.floor(((p[1] - minN) / n))

        s_dist = (p[0] - minM) - i*m # distance  
        t_dist = (p[1] - minN) - j*n # distance

        s = s_dist/m # scale to between (0,1)
        t = t_dist/n # scale to between (0,1)

        sum_wab2 = sum_w_ab2(s, t)

        for k in range(0, 4):
            for l in range(0, 4):
                w_kl = w(k, l, s, t)
                PHI_kl = w_kl * p[2]/sum_wab2
                delta[i+k, j+l] = delta[i+k, j+l] + PHI_kl * w_kl**2
                omg[i+k, j+l] = omg[i+k, j+l] + w_kl**2
        
    for i in range(0,u+3):
        for j in range(0,v+3):
            if omg[i, j] != 0:
                PHI[i, j] = delta[i, j]/omg[i, j]
        
    return PHI    

def find_gt(a, x):
    i = bisect_right(a, x)
    if i != len(a):
        return a[i], a[i-1],  i
    raise ValueError

def vfind_gt(a, x):
    ls = []
    for i in x:
        lb, ub, ind = find_gt(a,i)
        r = [lb, ub, ind]
        ls.append(r)
    return np.array(ls)

def BA_control_nonuni(points, xgrid, ygrid):
       
    minM = min(points[:,0])
    minN = min(points[:,1])

    u = len(xgrid)
    v = len(ygrid)

    delta = np.zeros((u+3, v+3))
    omg = np.zeros((u+3, v+3))
    PHI = np.zeros((u+3, v+3))

    for p in points:

        exmax, exmin, i = find_gt(xgrid, p[0] - minM)
        eymax, eymin, j = find_gt(ygrid, p[1] - minN) 

        s = (p[0] - minM - exmin)/(exmax - exmin)
        t = (p[1] - minN - eymin)/(eymax - eymin)

        sum_wab2 = sum_w_ab2(s, t)

        for k in range(0, 4):
            for l in range(0, 4):
                w_kl = w(k, l, s, t)
                PHI_kl = w_kl * p[2]/sum_wab2
                delta[i+k, j+l] = delta[i+k, j+l] + PHI_kl * w_kl**2
                omg[i+k, j+l] = omg[i+k, j+l] + w_kl**2
        
    for i in range(0,u+3):
        for j in range(0,v+3):
            if omg[i, j] != 0:
                PHI[i, j] = delta[i, j]/omg[i, j]
        
    return PHI

def evaluatePoint(x, y, points, Phi):

    intminM = np.floor(min(points[:,0]))
    intminN = np.floor(min(points[:,1]))

    i = int(np.floor(x) - intminM)
    j = int(np.floor(y) - intminN)
    s = x - np.floor(x)
    t = y - np.floor(y)

    f = 0

    for k in range(0,4):
        for l in range(0,4):
            f = f + Basis(k,s)*Basis(l,t)*Phi[i+k, j+l]
    
    return f

def evaluatePoint_Control(x, y, u, v, points, Phi):
    
    minM = min(points[:,0])
    minN = min(points[:,1])

    gridm = max(points[:,0]) - minM
    gridn = max(points[:,1]) - minN

    m = gridm/(u-1)
    n = gridn/(v-1)

    i = int(np.floor(((x - minM) / m)))
    j = int(np.floor(((y - minN) / n)))

    #s = ((x - minM) / m) - np.floor(((x - minM) / m))
    #t = ((y - minN) / n) - np.floor(((y - minN) / n))

    s_dist = (x - minM) - i*m # distance  
    t_dist = (y - minN) - j*n # distance

    s = s_dist/m # scale to between (0,1)
    t = t_dist/n # scale to between (0,1)

    f = 0

    for k in range(0,4):
        for l in range(0,4):
            f = f + Basis(k,s)*Basis(l,t)*Phi[i+k, j+l]
    
    return f

def evaluatePoint_Control_nonuni(x, y, xgrid, ygrid, points, Phi):
    
    minM = min(points[:,0])
    minN = min(points[:,1])

    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 

    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)

    f = 0

    for k in range(0,4):
        for l in range(0,4):
            f = f + Basis(k,s)*Basis(l,t)*Phi[i+k, j+l]
    
    return f


def evaluateSurface(X, Y, points, Phi):
    Z = np.zeros(np.shape(X))

    for i in range(0, np.shape(X)[0]):
        for j in range(0, np.shape(X)[1]):
            Z[i,j] = evaluatePoint(X[i,j], Y[i,j], points, Phi)

    return Z

def evaluateSurface_Control(X, Y, u, v, points, Phi):
    Z = np.zeros(np.shape(X))

    for i in range(0, np.shape(X)[0]):
        for j in range(0, np.shape(X)[1]):
            Z[i,j] = evaluatePoint_Control(X[i,j], Y[i,j], u, v, points, Phi)

    return Z

def evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, points, Phi):

    Z = np.zeros(np.shape(X))

    for i in range(0, np.shape(X)[0]):
        for j in range(0, np.shape(X)[1]):
            Z[i,j] = evaluatePoint_Control_nonuni(X[i,j], Y[i,j], xgrid, ygrid, points, Phi)

    return Z

def avgError(points, Phi):
    cumerror = 0
    for p in points:
        pred = evaluatePoint(p[0], p[1], points, Phi)
        error = abs(pred - p[2])
        cumerror = cumerror + error
        
    return cumerror/len(points)

def avgError_grid(points, xgrid, ygrid, Phi):
    cumerror = 0
    for p in points:
        pred = evaluatePoint_Control_nonuni(p[0], p[1], xgrid, ygrid, points, Phi)
        error = (pred - p[2])**2
        cumerror = cumerror + error
        
    return np.sqrt(cumerror/len(points))
