import numpy as np
from bisect import *

def Basis(d,k,t):
    """Evaluates Basis
    
    Arguments:
        d {[2,3]} -- degree of basis (2 or 3)
        k {int} -- the basis function to be evaluated (>= 0 and <= 3)
        t {float} -- local coordinate of point

    Returns:
        float -- evaluate basis at the local coordinates using the kth basis
    """
    # check that d,k,t are valid
    assert(d == 2 or d == 3)
    assert(0 <= t and t < 1) 
    assert(k<=3)
    # define basis functions based on degree
    basis = { 
        # cubic bsplines basis
        3:{
            0: (1 - t)**3/6, 
            1: (t * t * (3 * t - 6) + 4) / 6, 
            2: (t * (t * (-3 * t + 3) + 3) + 1) / 6, 
            3: t ** 3 / 6}, 
        # quadratic bsplines basis
        2:{
            0: (1-t)**2/2,
            1: (2*t*(1-t) + 1)/2, 
            2: t**2/2, 
        }
    }
    # return evaluated basis
    return basis[d][k]

def dBasis(d,k,t):
    """Evaluates Basis derivative
    
    Arguments:
        d {[2,3]} -- degree of basis (2 or 3)
        k {int} -- the basis function to be evaluated (>= 0 and <= 3)
        t {float} -- local coordinate of point

    Returns:
        float -- evaluate derivative of basis at the local coordinates using the kth basis
    """
    # check d, t, k are valid inputs
    assert(d == 2 or d == 3)
    assert(0 <= t and t < 1) 
    assert(k<=3) 
    # define basis based on degree
    dBasis = {
        # cubic bsplines basis
        3:{
            0: (-(1 - t)**2)/2,
            1: (t * (3 * t - 4))/2,
            2: (t * (2 - 3 * t) + 1)/2,
            3: (t**2) / 2},
        # quadratic bsplines basis
        2:{
            0: t - 1,
            1: -2*t + 1,
            2: t,
        }
    }
    # evaluate derivativive at d,k,t
    return dBasis[d][k]  

def vBasis(d,k,t):
    # vectorize Basis function
    vBasis = np.vectorize(Basis)
    return vBasis(d,k,t)

def vdBasis(d,k,t):
    # vectorize derivative of Basis function
    vdBasis = np.vectorize(dBasis)
    return vdBasis(d,k,t)

def vectorw(d, k, l, s, t):
    # evalute w
    return vBasis(d,k,s) * vBasis(d,l,t)

def vectorsum_w_ab2(d,s,t):
    # setup grid for every combination of k,l (0 <= k,l <=3)
    A,B = np.meshgrid(range(0,d+1),range(0,d+1))
    # return sum(w^2)
    return np.sum(vectorw(d,A,B,s,t)**2)

def find_gt(a, x):
    """find the position of point on the control grid
    
    Arguments:
        a {array} -- the control grid in one direction
        x {float} -- position of point in one direction
    
    Returns:
        max -- the max coordinate of the ensemble
        min -- the in coordinate of the ensemble
        index -- the index of the ensemble
    """
    # find where to inset point in array
    i = bisect_right(a, x)
    # if point is inserted at front of array
    if i <= 0:
        return a[0], a[0] - (a[1] - a[0]), i - 1
    # if point inserted within array
    elif i != len(a):
        return a[i], a[i-1],  i - 1 
    # if point inserted after array
    elif i >= len(a):
        return a[i-1] + (a[i-1] - a[i-2]), a[i-1], i - 1

def vfind_gt(a, x):
    """vectorize find_gt
    
    Arguments:
        a {array} -- the control grid in one direction
        x {float} -- position of point in one direction
    
    Returns:
        array -- [min, max, index] of ensemble
    """
    # initialise list
    ls = []
    # for point in points
    for i in x:
        # find max, min, index of ensemble corresponding to point
        ub, lb, ind = find_gt(a,i)
        # scale point between (0,1)
        d = (i - lb) / (ub - lb)
        # append to list
        r = [ub, lb, ind, d]
        ls.append(r)
    return np.array(ls)

def BA_control_nonuni(d, points, xgrid, ygrid):
    """evaluate control lattice (linear fit to points)
    
    Arguments:
        d {int} -- degree of basis
        points {matrix} -- points from pointcloud used to fit surface
        xgrid {array} -- control grid in x direction
        ygrid {array} -- control grid in y direction
    
    Returns:
        matrix -- (u+2) by (v+2) control grid (model parameters)
    """ 
    # get min x,y coordinate in points
    minM = min(points[:,0])
    minN = min(points[:,1])

    # get number of control points in x,y direction
    u = len(xgrid)
    v = len(ygrid)

    # initialise delta, omega, and Phi
    delta = np.zeros((u+2, v+2))
    omg = np.zeros((u+2, v+2))
    PHI = np.zeros((u+2, v+2))

    # for each point in points
    for p in points:

        # get the min, max, index of ensemble that corresponds to the point
        exmax, exmin, i = find_gt(xgrid, p[0] - minM)
        eymax, eymin, j = find_gt(ygrid, p[1] - minN) 

        # get local coordinate of point (scaled between 0,1)
        s = (p[0] - minM - exmin)/(exmax - exmin)
        t = (p[1] - minN - eymin)/(eymax - eymin)

        # evaluate sum(w^2)
        sum_wab2 = vectorsum_w_ab2(d, s, t)

        # sum effect of point over support of basis
        for k in range(0, d+1):
            for l in range(0, d+1):
                # evaluate w
                w_kl = vectorw(d, k, l, s, t)
                # evaluate phi
                PHI_kl = w_kl * p[2]/sum_wab2
                # calculate delta and omega kl
                delta[i+k, j+l] = delta[i+k, j+l] + PHI_kl * w_kl**2
                omg[i+k, j+l] = omg[i+k, j+l] + w_kl**2
        
    # coordinate effect of points on control points in least squares way 
    for i in range(0,u+2):
        for j in range(0,v+2):
            if omg[i, j] != 0:
                PHI[i, j] = delta[i, j]/omg[i, j]
        
    return PHI

def evaluatePoint_Control_nonuni(d, x, y, xgrid, ygrid, xyrange, Phi):
    """evaluate Z for array of x,y
    
    Arguments:
        d {int} -- degree of basis (2 or 3)
        x {float} -- x coordinate of point
        y {float} -- y coordinate of point
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x and y of point cloud
        Phi {matrix} -- control lattice (model parameters) 
    
    Returns:
        float -- predictions
    """
    # get min x and y
    minM, minN = xyrange
    # evaluate min, max, and index of ensemble corresponding to each point
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    # if index out of range then return 0
    if (i >= len(xgrid) - 1) | (i < 0) | (j >= len(ygrid) - 1) | (j < 0):
        return 0
    # get local coordinates
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)
    # evaluate each Basis for the local coordiante
    Bs = vBasis(d, range(0,d+1), s)
    Bt = vBasis(d, range(0,d+1), t)
    f = np.outer(Bs, Bt) * Phi[i:i+4, j:j+4]
    return np.sum(f)

def vevaluatePoint_Control_nonuni(d, x, y, xgrid, ygrid, xyrange, Phi):   
    """evaluate Z for array of x,y
    
    Arguments:
        d {int} -- degree of basis (2 or 3)
        x {float} -- x coordinate of point
        y {float} -- y coordinate of point
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x and y of point cloud
        Phi {matrix} -- control lattice (model parameters) 
    
    Returns:
        array -- predictions
    """
    # get min x and y
    minM, minN = xyrange
    # evaluate min, max, and index of ensemble corresponding to each point
    xls = vfind_gt(xgrid, x - minM)
    yls = vfind_gt(ygrid, y - minN)
    # inialise z for each point
    f = np.zeros(np.shape(x))
    # loop over control points that effect each point
    for k in range(0,d+1):
        for l in range(0,d+1):
            # evaluate z
            f = f + vectorw(d, k, l, xls[:,3], yls[:,3])*Phi[xls[:,2].astype(int)+k,yls[:,2].astype(int)+l]  
    return f   

'''
def vectordw(d, k, l, s, t):
    # vectorize evaluation of dw
    return vdBasis(d,k,s) * vBasis(d,l,t) + vBasis(d,k,s) * vdBasis(d,l,t)
'''

def evaluateSurface_Control_nonuni(d, X, Y, xgrid, ygrid, xyrange, Phi):
    # initialise grid for Z 
    Z = np.zeros(np.shape(X)) 
    # for each row in grid
    for i in range(0, np.shape(X)[0]):
        # evaluate each row of Z
        Z[i,:] = vevaluatePoint_Control_nonuni(d, X[i,:], Y[i,:], xgrid, ygrid, xyrange, Phi)
    return Z

def Error(d, points, xgrid, ygrid, Phi):
    """calculate error of fit
    
    Arguments:
        d {int} -- degree of basis 2 or 3
        points {matrix} -- point cloud
        xgrid {array} -- control points in x
        ygrid {array} -- control points in y
        Phi {matrix} -- control point lattice (model parameters)
    
    Returns:
        RMSE -- root mean squared error
        SSE -- sum of squared errors
    """
    # get min x,y 
    xyrange = [min(points[:,0]), min(points[:,1])]
    # evaluate z for all x,y 
    pred = vevaluatePoint_Control_nonuni(d, points[:,0], points[:,1], xgrid, ygrid, xyrange, Phi)
    # calculate errors
    error = pred - points[:,2]
    # calculate errors
    RMSE = np.sqrt(np.mean(error**2))
    SSE = np.sum(error**2)
    return RMSE, SSE