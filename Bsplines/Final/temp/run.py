import numpy as np
import BAtest as BA
import optimisation as o
import setting

setting.init()
Phi = setting.Phi_control_nonuni
points = setting.points
xgrid = setting.xgrid
ygrid = setting.ygrid
xyrange = setting.xyrange

#res = o.nonlinear_errors(Phi, points, xgrid, ygrid, xyrange)
#665761.8452114458

field = o.field_nonlinear(Phi, points, xgrid, ygrid, xyrange)
resx = field.x.reshape(len(xgrid) + 2, len(ygrid) + 2)
np.savetxt("NLPhi.csv", resx, delimiter=",")

from numpy import genfromtxt
newPhi = genfromtxt('NLPhi.csv', delimiter=',')
#field = o.field_nonlinear(newPhi, points, xgrid, ygrid, xyrange)


print(field.fun)
print(field.message)
'''
#from numpy import genfromtxt
#newPhi = genfromtxt('Phi2.csv', delimiter=',')

#res2 = o.nonlinear_errors(newPhi, points, xgrid, ygrid, xyrange)
#466748.62296980165

tx = points[:,0]
ty = points[:,1]

X = np.arange(np.ceil(min(tx)),np.floor(max(tx)), 1)
Y = np.arange(np.ceil(min(ty)),np.floor(max(ty)), 1)

X,Y = np.meshgrid(X,Y)

Z = BA.evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, xyrange, newPhi)

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(1)

plt.clf()
ax = Axes3D(fig, rect=[0, 0, 1, 1], elev=90, azim=0)
ax.plot_surface(X, Y, Z)
plt.show(block=True)
'''