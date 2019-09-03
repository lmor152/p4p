from BAtest import *
import scipy.optimize
import multiprocessing as mp

'''
def evaluatePoint_Control_nonuni(x, y, xgrid, ygrid, xyrange, Phi):
    minM = xyrange[0]
    minN = xyrange[1]
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    if (i >= len(xgrid)) | (i <= 0) | (j >= len(ygrid)) | (j <= 0):
        return 0
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)
    f = 0
    for k in range(0,4):
        for l in range(0,4):
            f = f + Basis(k,s)*Basis(l,t)*Phi[i+k, j+l]  
    return f
'''

def evaluatePoint_Control_nonuni(x, y, xgrid, ygrid, xyrange, Phi):
    minM, minN = xyrange
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)
    Bs = vBasis(range(0,4), s)
    Bt = vBasis(range(0,4), t)
    f = np.outer(Bs, Bt) * Phi[i:i+4, j:j+4]
    return np.sum(f)

def obj(est, point, xgrid, ygrid, xyrange, Phi):
    try:
        z = evaluatePoint_Control_nonuni(est[0], est[1], xgrid, ygrid, xyrange, Phi)
    except:
        z = 0
    return (point[0] - est[0])**2 + (point[1] - est[1])**2 + (point[2] - z)**2

def jac(est, point, xgrid, ygrid, xyrange, Phi):
    z = evaluatePoint_Control_nonuni(est[0], est[1], xgrid, ygrid, xyrange, Phi)
    dfdu = df(est[0], est[1], xgrid, ygrid, xyrange, Phi)
    dfdx = -2*(point[0] - est[0]) - 2*dfdu[0]*(point[2] - z)
    dfdy = -2*(point[1] - est[1]) - 2*dfdu[1]*(point[2] - z)
    return np.array([dfdx, dfdy])            

def df(x, y, xgrid, ygrid, xyrange, Phi):
    minM, minN = xyrange
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    if (i >= len(xgrid)) | (i < 0) | (j >= len(ygrid)) | (j < 0):
        return np.array([0,0])
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)
    dx = 0
    dy = 0
    for k in range(0,4):
        for l in range(0,4):
            dx = dx + dBasis(k,s)*Basis(l,t)*Phi[i+k, j+l] / (exmax - exmin)   
            dy = dy + Basis(k,s)*dBasis(l,t)*Phi[i+k, j+l] / (eymax - eymin)
    return np.array([dx, dy])    

def df_surf(x, y, xgrid, ygrid, xyrange, Phi):
    minM, minN = xyrange
    exmax, exmin, i = find_gt(xgrid, x - minM)
    eymax, eymin, j = find_gt(ygrid, y - minN) 
    if (i >= len(xgrid)) | (i < 0) | (j >= len(ygrid)) | (j < 0):
        return np.array([0,0])
    s = (x - minM - exmin)/(exmax - exmin)
    t = (y - minN - eymin)/(eymax - eymin)  
    dBs = vdBasis(range(0,4), s)
    dBt = vdBasis(range(0,4), t)
    Bs = vBasis(range(0,4), s)
    Bt = vBasis(range(0,4), t)
    dx = np.outer(dBs, Bt) * Phi[i:i+4, j:j+4] / (exmax - exmin)
    dy = np.outer(Bs, dBt) * Phi[i:i+4, j:j+4] / (exmax - exmin)
    return np.array([np.sum(dx), np.sum(dy)])

def lattice_df(Phi, points, xgrid, ygrid, xyrange):
    Phi = Phi.reshape(len(xgrid) + 2, len(ygrid) + 2)
    minM, minN = xyrange
    dPhi = np.zeros(np.shape(Phi))
    global est
    xls = vfind_gt(xgrid, est[:,0] - minM)
    yls = vfind_gt(ygrid, est[:,1] - minN)
    evals = vevaluatePoint_Control_nonuni(est[:,0], est[:,1], xgrid, ygrid, xyrange, Phi)
    error = points[:,2] - evals
    for q in range(0, len(error)):
        Bs = vBasis(range(0,4), xls[q,3])
        Bt = vBasis(range(0,4), yls[q,3])
        delPhi = -2 * np.outer(Bs, Bt) * error[q]
        i = int(xls[q,2])
        j = int(yls[q,2])
        dPhi[i:i+4, j:j+4] = delPhi + dPhi[i:i+4, j:j+4]
    return dPhi

def mp_nonlinearOptim(e, p, xgrid, ygrid, xyrange, Phi):
    res = scipy.optimize.minimize(obj, e, args = (p, xgrid, ygrid, xyrange, Phi), jac = jac)
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
    est = points[:,0:2]
    result = scipy.optimize.minimize(nonlinear_errors, Phi, args = (points, xgrid, ygrid, xyrange), jac = lattice_df)
    return result.x 

    



