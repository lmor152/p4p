from BAquad import *
import scipy.optimize
import multiprocessing as mp
 
def obj(est, point, xgrid, ygrid, xyrange, Phi, d):
    """calculate euclidean error
    
    Arguments:
        est {array} -- initial guess of (x',y')
        point {array} -- data point (x,y,z)
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        Phi {matrix} -- control lattice
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        float -- euclidean distance between point (x,y,z) and guess (x',y',f(x',y'))
    """

    z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    # return distance
    return (point[0] - est[0])**2 + (point[1] - est[1])**2 + (point[2] - z)**2

def jac(est, point, xgrid, ygrid, xyrange, Phi, d):
    """calculate jacobian
    
    Arguments:
        est {array} -- initial guess of (x',y')
        point {array} -- data point (x,y,z)
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        Phi {matrix} -- control lattice
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        array - jacobian of objective function
    """
    # evaluate z
    z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    # calculate derivative of surface
    dfdu = df(est[0], est[1], xgrid, ygrid, xyrange, Phi, d)
    # get jacobian for objective function
    dfdx = -2*(point[0] - est[0]) - 2*dfdu[0]*(point[2] - z)
    dfdy = -2*(point[1] - est[1]) - 2*dfdu[1]*(point[2] - z)
    d = np.array([dfdx, dfdy])  
    return d  

def hessian(est, point, xgrid, ygrid, xyrange, Phi, d):
    z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    dfdu = df(est[0], est[1], xgrid, ygrid, xyrange, Phi, d)
    ddfdu2 = ddf(est[0], est[1], xgrid, ygrid, xyrange, Phi, d)  
    ddx2 = -2 * ddfdu2[0,0]*(point[2] - z) + 2*dfdu[0]**2 + 2
    ddy2 = -2 * ddfdu2[1,1]*(point[2] - z) + 2*dfdu[1]**2 + 2
    ddxy = -2 * ddfdu2[0,1]*(point[2] - z) + 2*dfdu[0]*dfdu[1]
    return np.array([[ddx2, ddxy], [ddxy, ddy2]])

def df(x, y, xgrid, ygrid, xyrange, Phi, d):
    """calculate surface derivative
    
    Arguments:
        x {float} -- x coordinate
        y {float} -- y coordinate
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        Phi {matrix} -- control lattice
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        array - surface derivative 
    """
    # get min x,y coordinate in points
    minM, minN = xyrange
    # get the min, max, index of ensemble that corresponds to the point
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    # if index out of range
    if (i >= len(xgrid) - 1) | (i < 0) | (j >= len(ygrid) - 1) | (j < 0):
        eps = 1e-6
        # evaluate numerical derivative
        Z = evaluatePoint_Control_nonuni(d, x, y, xgrid, ygrid, xyrange, Phi)
        Zxdash = evaluatePoint_Control_nonuni(d, x + eps, y, xgrid, ygrid, xyrange, Phi)
        Zydash = evaluatePoint_Control_nonuni(d, x, y + eps, xgrid, ygrid, xyrange, Phi)
        return np.array([(Zxdash - Z)/eps, (Zydash - Z)/eps])
    # get local coordinate of point (scaled between 0,1)
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)  
    # evaluate derivatives for each affected control point by the point 
    dBs = vdBasis(d, range(0,d+1), s)
    dBt = vdBasis(d, range(0,d+1), t)
    Bs = vBasis(d, range(0,d+1), s)
    Bt = vBasis(d, range(0,d+1), t)
    dx = np.outer(dBs, Bt) * Phi[i:i+(d+1), j:j+(d+1)] / (exmax - exmin)
    dy = np.outer(Bs, dBt) * Phi[i:i+(d+1), j:j+(d+1)] / (eymax - eymin)
    return np.array([np.sum(dx), np.sum(dy)])


def ddf(x, y, xgrid, ygrid, xyrange, Phi, d):
    """calculate surface second derivative

    Arguments:
        x {float} -- x coordinate
        y {float} -- y coordinate
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        Phi {matrix} -- control lattice
        d {int} -- Basis degree (2 or 3)

    Returns:
        array - surface derivative 
    """
    # get min x,y coordinate in points
    minM, minN = xyrange
    # get the min, max, index of ensemble that corresponds to the point
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    # if index out of range
    if (i >= len(xgrid) - 1) | (i < 0) | (j >= len(ygrid) - 1) | (j < 0):
        return np.array([[0,0], [0,0]])
    # get local coordinate of point (scaled between 0,1)
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)  
    # evaluate derivatives for each affected control point by the point 
    ddBs = vddBasis(d, range(0,d+1), s)
    ddBt = vddBasis(d, range(0,d+1), t)
    dBs = vdBasis(d, range(0,d+1), s)
    dBt = vdBasis(d, range(0,d+1), t)
    Bs = vBasis(d, range(0,d+1), s)
    Bt = vBasis(d, range(0,d+1), t)
    ddx2 = np.outer(ddBs, Bt) * Phi[i:i+(d+1), j:j+(d+1)] / ((exmax - exmin)**2)
    ddy2 = np.outer(Bs, ddBt) * Phi[i:i+(d+1), j:j+(d+1)] / ((eymax - eymin)**2)
    ddxy = np.outer(dBs, dBt) * Phi[i:i+(d+1), j:j+(d+1)] / ((eymax - eymin) * (exmax - exmin))
    return np.array([[np.sum(ddx2), np.sum(ddxy)], [np.sum(ddxy), np.sum(ddy2)]])   

def newlattice_df(Phi, points, xgrid, ygrid, xyrange, d):
    Phi = Phi.reshape(len(xgrid)+d-1, len(ygrid)+d-1)
    # get min x,y coordinate in points
    minM, minN = xyrange
    # initialise dPhi
    dPhi = np.zeros(np.shape(Phi))
    import setting
    est = setting.est
    for ind, p in enumerate(points):
        exmax, exmin, i = find_gt(xgrid, est[ind,0] - minM)
        eymax, eymin, j = find_gt(ygrid, est[ind,1] - minN)
        s = (est[ind,0] - minM - exmin)/(exmax - exmin)
        t = (est[ind,0] - minN - eymin)/(eymax - eymin)
        z = evaluatePoint_Control_nonuni(d, est[ind, 0], est[ind, 1], xgrid, ygrid, xyrange, Phi)
        e = (p[2] - z)
        for k in range(0,d+1):
            for l in range(0,d+1):
                dPhi[i+k,j+l] = dPhi[i+k,j+l] -2*vectorw(d,k,l,s,t)*e
    return dPhi.flatten()


def lattice_df(Phi, points, xgrid, ygrid, xyrange, d):
    """calculate jacobian for Phi
    
    Arguments:
        Phi {matrix} -- control lattice
        points {matrix} -- point cloud
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        array - jacobian of model parameters
    """
    # reshape Phi 
    Phi = Phi.reshape(len(xgrid)+d-1, len(ygrid)+d-1)
    # get min x,y coordinate in points
    minM, minN = xyrange
    # initialise dPhi
    dPhi = np.zeros(np.shape(Phi))
    import setting
    est = setting.est
    # evaluate min, max, and index of ensemble corresponding to each point
    xls = vfind_gt(xgrid, est[:,0] - minM)
    yls = vfind_gt(ygrid, est[:,1] - minN)

    # evaluate model at estimates
    evals = vevaluatePoint_Control_nonuni(d, est[:,0], est[:,1], xgrid, ygrid, xyrange, Phi)
    # calculate errors
    error = points[:,2] - evals
    # for each point
    for q in range(0, len(error)):
        # evaluate basis for each control point
        Bs = vBasis(d, range(0,d+1), xls[q,3])
        Bt = vBasis(d, range(0,d+1), yls[q,3])
        # calculate change in Phi    
        delPhi = -2 * np.outer(Bs, Bt) * error[q]
        i = int(xls[q,2])
        j = int(yls[q,2])
        # sum dPhi over all points
        dPhi[i:i+(d+1), j:j+(d+1)] = delPhi + dPhi[i:i+(d+1), j:j+(d+1)]
    return dPhi.flatten()

def mp_nonlinearOptim(e, p, xgrid, ygrid, xyrange, Phi, d):
    """get euclidean closest model point to data point 
    
    Arguments:
        e {array} -- estimate point (x', y')
        p {array} -- data point (x, y, z)
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        Phi {matrix} -- control lattice
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        res.x - euclidean closest point (x',y') on model to data point (x,y,z) 
        res.fun - closest euclidean distance of data point to surface 
    """
    # run scipy optimise
    #res = scipy.optimize.minimize(obj, e, args = (p, xgrid, ygrid, xyrange, Phi, d), method = 'Newton-CG', jac = jac, hess = hessian)
    res = scipy.optimize.minimize(obj, e, args = (p, xgrid, ygrid, xyrange, Phi, d), method = 'BFGS', jac = jac)
    if not res.success:
       res = scipy.optimize.minimize(obj, res.x, method = 'nelder-mead', args = (p, xgrid, ygrid, xyrange, Phi, d))
    return res.x, res.fun

def nonlinear_errors(Phi, points, xgrid, ygrid, xyrange, d):
    """get sum of euclidean closest distances over all point cloud points
    
    Arguments:
        Phi {matrix} -- control lattice
        points {matrix} -- point cloud
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        float -- sum of closest euclidean distances 
    """
    # reshape Phi
    Phi = Phi.reshape(len(xgrid) + d - 1, len(ygrid) + d - 1)
    # use multi core processing to speed up computation
    pool = mp.Pool(mp.cpu_count())
    import setting
    # run mp_nonlinearOptim for all points
    result = pool.starmap(mp_nonlinearOptim, [(e, p, xgrid, ygrid, xyrange, Phi, d) for (e,p) in zip(setting.est, points)])
    result = np.array(result)
    # update est
    est = result[:,0]
    est = np.array(est.tolist())
    setting.est = est
    pool.close()
    return np.sum(result[:,1])

def field_nonlinear(Phi, points, xgrid, ygrid, xyrange, d, maxit):
    """get best model parameters
    
    Arguments:
        Phi {matrix} -- control lattice
        points {matrix} -- point cloud
        xgrid {array} -- control points in x direction
        ygrid {array} -- control points in y direction
        xyrange {array} -- min x,y of point cloud
        d {int} -- Basis degree (2 or 3)
    
    Returns:
        array - best model parameters
    """
    # optimise nonlinear_errors with respect to model parameters
    result = scipy.optimize.minimize(nonlinear_errors, Phi.flatten(), args = (points, xgrid, ygrid, xyrange, d), jac = lattice_df, options = {'maxiter':maxit, 'disp':True})
    return result 

def texture_obj(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d):
    z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    '''
    normv1 = (est[0]-impoint[0])**2 +  (est[1]-impoint[1])**2 + z**2 
    num = ((origin[0] - impoint[0])*(est[0] - impoint[0]) + (origin[1] - impoint[1])*(est[1] - impoint[1]) + origin[2]*z)**2
    denom = (origin[0] - est[0])**2 + (origin[1] - est[1])**2 + origin[2]**2
    d2 = normv1 - num/denom
    '''
    v1 = np.array([est[0], est[1], z])  - np.array([impoint[0], impoint[1], 0])
    v2 = origin - np.array([impoint[0], impoint[1], 0])
    d2 = sum(v1**2) - (np.dot(v1,v2)**2) / sum(v2**2)
    return d2

def texture_jac(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d):
    z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    dfdu = df(est[0], est[1], xgrid, ygrid, xyrange, Phi, d)
    denom = (origin[0] - est[0])**2 + (origin[1] - est[1])**2 + origin[2]**2
    ex1 = 2*(est[0] - impoint[0])
    ex2 = 2*z*dfdu[0]
    numx1 = 2*(origin[0] - est[0])*((origin[0] - impoint[0])*(est[0] - impoint[0]) + (origin[1] - impoint[1])*(est[1] - impoint[1]) + origin[2]*z)**2
    numx2 = 2*(origin[2]*dfdu[0] + origin[0] - impoint[0])*((origin[0] - impoint[0])*(est[0] - impoint[0]) + (origin[1] - impoint[1])*(est[1] - impoint[1]) + origin[2]*z)
    dfdx = ex1 + ex2 - numx1/denom**2 - numx2/denom
    ey1 = 2*(est[1] - impoint[1])
    ey2 = 2*z*dfdu[1]
    numy1 = 2*(origin[1] - est[1])*((origin[0] - impoint[0])*(est[0] - impoint[0]) + (origin[1] - impoint[1])*(est[1] - impoint[1]) + origin[2]*z)**2
    numy2 = 2*(origin[2]*dfdu[1] + origin[1] - impoint[1])*((origin[0] - impoint[0])*(est[0] - impoint[0]) + (origin[1] - impoint[1])*(est[1] - impoint[1]) + origin[2]*z)
    dfdy = ey1 + ey2 - numy1/denom**2 - numy2/denom
    return np.array([dfdx,dfdy]) 

def texture_opt(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d):
    res = scipy.optimize.minimize(texture_obj, est, args = (origin, impoint, xgrid, ygrid, xyrange, Phi, d), options = {'disp':False}, jac = texture_jac)
    if not res.success:
        res = scipy.optimize.minimize(texture_obj, res.x, args = (origin, impoint, xgrid, ygrid, xyrange, Phi, d), method= 'Nelder-Mead',options = {'disp':False})
    return res.x, res.success

def texture_coords(Phi, est, origin, impoint, xgrid, ygrid, xyrange, d):
    # reshape Phi
    Phi = Phi.reshape(len(xgrid) + d - 1, len(ygrid) + d - 1)
    # use multi core processing to speed up computation
    pool = mp.Pool(mp.cpu_count())
    result = pool.starmap(texture_opt, [(e, origin, e, xgrid, ygrid, xyrange, Phi, d) for e in est])
    result = np.array(result)
    pool.close()
    return result

