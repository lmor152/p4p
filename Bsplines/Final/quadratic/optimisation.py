from BAtest import *
import scipy.optimize
import multiprocessing as mp
 
def obj(est, point, xgrid, ygrid, xyrange, Phi, d):
    try:
        z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    except:
        z = 0
    return (point[0] - est[0])**2 + (point[1] - est[1])**2 + (point[2] - z)**2

def jac(est, point, xgrid, ygrid, xyrange, Phi, d):
    z = evaluatePoint_Control_nonuni(d, est[0], est[1], xgrid, ygrid, xyrange, Phi)
    dfdu = df(est[0], est[1], xgrid, ygrid, xyrange, Phi, d)
    dfdx = -2*(point[0] - est[0]) - 2*dfdu[0]*(point[2] - z)
    dfdy = -2*(point[1] - est[1]) - 2*dfdu[1]*(point[2] - z)
    return np.array([dfdx, dfdy])            

def df(x, y, xgrid, ygrid, xyrange, Phi, d):
    minM, minN = xyrange
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    if (i >= len(xgrid) - 1) | (i < 0) | (j >= len(ygrid) - 1) | (j < 0):
        eps = 1e-6
        Z = evaluatePoint_Control_nonuni(d, x, y, xgrid, ygrid, xyrange, Phi)
        Zxdash = evaluatePoint_Control_nonuni(d, x + eps, y, xgrid, ygrid, xyrange, Phi)
        Zydash = evaluatePoint_Control_nonuni(d, x, y + eps, xgrid, ygrid, xyrange, Phi)
        return np.array([(Zxdash - Z)/eps, (Zydash - Z)/eps])
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)
    dx = 0
    dy = 0
    for k in range(0,d+1):
        for l in range(0,d+1):
            dx = dx + dBasis(d,k,s)*Basis(d,l,t)*Phi[i+k, j+l] / (exmax - exmin)   
            dy = dy + Basis(d,k,s)*dBasis(d,l,t)*Phi[i+k, j+l] / (eymax - eymin)
    return np.array([dx, dy])    

def df_surf(x, y, xgrid, ygrid, xyrange, Phi, d):
    minM, minN = xyrange
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    if (i >= len(xgrid) - 1) | (i < 0) | (j >= len(ygrid) - 1) | (j < 0):
        eps = 1e-6
        Z = evaluatePoint_Control_nonuni(d, x, y, xgrid, ygrid, xyrange, Phi)
        Zxdash = evaluatePoint_Control_nonuni(d, x + eps, y, xgrid, ygrid, xyrange, Phi)
        Zydash = evaluatePoint_Control_nonuni(d, x, y + eps, xgrid, ygrid, xyrange, Phi)
        return np.array([(Zxdash - Z)/eps, (Zydash - Z)/eps])
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)  
    dBs = vdBasis(d, range(0,d+1), s)
    dBt = vdBasis(d, range(0,d+1), t)
    Bs = vBasis(d, range(0,d+1), s)
    Bt = vBasis(d, range(0,d+1), t)
    dx = np.outer(dBs, Bt) * Phi[i:i+4, j:j+4] / (exmax - exmin)
    dy = np.outer(Bs, dBt) * Phi[i:i+4, j:j+4] / (exmax - exmin)
    return np.array([np.sum(dx), np.sum(dy)])

def lattice_df(Phi, points, xgrid, ygrid, xyrange, d):
    Phi = Phi.reshape(len(xgrid) + 2, len(ygrid) + 2)
    minM, minN = xyrange
    dPhi = np.zeros(np.shape(Phi))
    try:
        est = setting.est
    except:
        est = points[:,0:2]
    xls = vfind_gt(xgrid, est[:,0] - minM)
    yls = vfind_gt(ygrid, est[:,1] - minN)
    evals = vevaluatePoint_Control_nonuni(d, est[:,0], est[:,1], xgrid, ygrid, xyrange, Phi)
    error = points[:,2] - evals
    for q in range(0, len(error)):
        Bs = vBasis(d, range(0,d+1), xls[q,3])
        Bt = vBasis(d, range(0,d+1), yls[q,3])
        delPhi = -2 * np.outer(Bs, Bt) * error[q]
        i = int(xls[q,2])
        j = int(yls[q,2])
        dPhi[i:i+4, j:j+4] = delPhi + dPhi[i:i+4, j:j+4]
    return dPhi.flatten()

def mp_nonlinearOptim(e, p, xgrid, ygrid, xyrange, Phi, d):
    res = scipy.optimize.minimize(obj, e, args = (p, xgrid, ygrid, xyrange, Phi, d), jac = jac)
    return res.x, res.fun   

def nonlinear_errors(Phi, points, xgrid, ygrid, xyrange, d):
    Phi = Phi.reshape(len(xgrid) + 2, len(ygrid) + 2)
    pool = mp.Pool(mp.cpu_count())
    import setting
    setting.init_est(points)
    result = pool.starmap(mp_nonlinearOptim, [(e, p, xgrid, ygrid, xyrange, Phi, d) for (e,p) in zip(setting.est, points)])
    result = np.array(result)
    est = result[:,0]
    est = np.array(est.tolist())
    setting.est = est
    pool.close()
    return np.sum(result[:,1])

def field_nonlinear(Phi, points, xgrid, ygrid, xyrange, d):
    result = scipy.optimize.minimize(nonlinear_errors, Phi.flatten(), args = (points, xgrid, ygrid, xyrange, d), jac = lattice_df, options = {'maxiter':1, 'disp':True})
    return result 





