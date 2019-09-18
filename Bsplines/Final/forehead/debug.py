import numpy as np
from numpy import genfromtxt
import BAquad as BA
import setting
import optimisation as o
from plyfile import PlyData, PlyElement
import cv2
import texturemapping as t
import multiprocessing as mp
try:
    mp.set_start_method('spawn')
except RuntimeError:
    pass

eps = 1e-6
solve = False
field = True
u = 5
v = 5
d = 3

ptcFileName = 'forehead.ply'
xgridFile = 'xgrid_forehead.csv'
ygridFile = 'ygrid_forehead.csv'
PhiFile = 'Phi_forehead'
NLPhiFile = 'NLPhi_forehead'

setting.init(solve, u, v, eps, d, xgridFile, ygridFile, PhiFile, ptcFileName)
Phi = setting.Phi_control_nonuni
points = setting.points
xgrid = setting.xgrid
ygrid = setting.ygrid
xyrange = setting.xyrange
centroid = setting.centroid
V = setting.V
plane = setting.plane

setting.init_est(points)
res = o.nonlinear_errors(Phi, points, xgrid, ygrid, xyrange, d)
o.lattice_df(Phi, points, xgrid, ygrid, xyrange, d)