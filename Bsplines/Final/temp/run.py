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
np.savetxt("NLPhi200.csv", resx, delimiter=",")

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

tx = points[:,0]
ty = points[:,1]

X = np.arange(np.ceil(min(tx)),np.floor(max(tx)), 1)
Y = np.arange(np.ceil(min(ty)),np.floor(max(ty)), 1)

X,Y = np.meshgrid(X,Y)

Z = BA.evaluateSurface_Control_nonuni(X, Y, xgrid, ygrid, xyrange, newPhi)


import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Create figure.
fig = plt.figure()
ax = fig.gca(projection = '3d')

# Generate example data.

# Plot the data.
surf = ax.plot_surface(X, Y, Z)

max_range = np.array([X.max()-X.min(), Y.max()-Y.min(), Z.max()-Z.min()]).max() / 2.0

mid_x = (X.max()+X.min()) * 0.5
mid_y = (Y.max()+Y.min()) * 0.5
mid_z = (Z.max()+Z.min()) * 0.5
ax.set_xlim(mid_x - max_range, mid_x + max_range)
ax.set_ylim(mid_y - max_range, mid_y + max_range)
ax.set_zlim(mid_z - max_range, mid_z + max_range)

#plt.show(block=True)
# Set viewpoint.
ax.azim = 130
ax.elev = -120

#fig.savefig('face.png')
plt.show(block=True)