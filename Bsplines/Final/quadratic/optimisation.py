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
    try:
        # evaluate z
        z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    except:
        # if error z = 0
        z = 0
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
    return np.array([dfdx, dfdy])            
'''
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
    dx = 0
    dy = 0
    # loop over control points that effect each point
    for k in range(0,d+1):
        for l in range(0,d+1):
            # evaluate derivatives
            dx = dx + dBasis(d,k,s)*Basis(d,l,t)*Phi[i+k, j+l] / (exmax - exmin)   
            dy = dy + Basis(d,k,s)*dBasis(d,l,t)*Phi[i+k, j+l] / (eymax - eymin)
    return np.array([dx, dy])    
'''
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
    # get est from setting
    try:
        est = setting.est
    except:
        est = points[:,0:2]
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
        # calculate cahnge in Phi    
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
    res = scipy.optimize.minimize(obj, e, args = (p, xgrid, ygrid, xyrange, Phi, d), jac = jac)
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
    # get est
    setting.init_est(points)
    # run mp_nonlinearOptim for all points
    result = pool.starmap(mp_nonlinearOptim, [(e, p, xgrid, ygrid, xyrange, Phi, d) for (e,p) in zip(setting.est, points)])
    result = np.array(result)
    # update est
    est = result[:,0]
    est = np.array(est.tolist())
    setting.est = est
    pool.close()
    return np.sum(result[:,1])

def field_nonlinear(Phi, points, xgrid, ygrid, xyrange, d):
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
    result = scipy.optimize.minimize(nonlinear_errors, Phi.flatten(), args = (points, xgrid, ygrid, xyrange, d), jac = lattice_df, options = {'maxiter':1, 'disp':True})
    return result 





