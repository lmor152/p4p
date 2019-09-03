import numpy as np

def obj(est, point):
    z = est[0]**2 + est[1]**2 
    return (point[0] - est[0])**2 + (point[1] - est[1])**2 + (point[2] - z)**2

def jac(est, point):
    z = est[0]**2 + est[1]**2 
    dfdx = -2*(point[0] - est[0]) - 2*2*est[0]*(point[2] - z)
    dfdy = -2*(point[1] - est[1]) - 2*2*est[1]*(point[2] - z)
    return np.array([dfdx, dfdy])