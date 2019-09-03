import numpy as np
import BA
from initgrid import *

from sklearn.decomposition import PCA

from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

from plyfile import PlyData

mesh = PlyData.read('pc.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]

r = mesh.elements[0]['red']
g = mesh.elements[0]['blue']
b = mesh.elements[0]['green']

colors = np.c_[r, g, b]

pca = PCA(n_components=3)

pca.fit(points)
pca_score = pca.explained_variance_ratio_
V = pca.components_

tpts = pca.transform(points)
tx = tpts[:, 0]
ty = tpts[:, 1]
tz = tpts[:, 2]

points = np.c_[tx,ty,tz]

u = 10
v = 10

def xonclick(event):
    global ix
    ix = event.xdata
    global xcoords
    xcoords.append(ix)
    plt.axvline(ix, color = 'k')
    fig.canvas.draw()
    global u
    if len(xcoords) == u:
        fig.canvas.mpl_disconnect(cid)
        plt.close()
    return


plt.ion()
fig = plt.figure(1)
plt.scatter(tx, ty, c = np.double(colors)/255.0)
plt.axvline(min(tx), color = 'k')
plt.axvline(max(tx), color = 'k')
xcoords = [min(tx), max(tx)]
cid = fig.canvas.mpl_connect('button_press_event', xonclick)

def yonclick(event):
    global iy
    iy = event.ydata
    global ycoords
    ycoords.append(iy)
    plt.axhline(iy, color = 'k')
    fig.canvas.draw()
    global v
    if len(ycoords) == v:
        fig.canvas.mpl_disconnect(cid)
        plt.close()
    return

plt.ion()
fig = plt.figure(1)
plt.scatter(tx, ty, c = np.double(colors)/255.0)
plt.axhline(min(ty), color = 'k')
plt.axhline(max(ty), color = 'k')
ycoords = [min(ty), max(ty)]
cid = fig.canvas.mpl_connect('button_press_event', yonclick)
plt.show(block = True)

print(xcoords)
print(ycoords)