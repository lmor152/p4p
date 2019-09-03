from geomdl import construct
from geomdl import fitting
from geomdl.visualization import VisMPL as vis

from plyfile import PlyData
import numpy as np


mesh = PlyData.read('uniformptc.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]
points = tuple(map(tuple, points))

size_u = 500
size_v = 500

degree_u = 3
degree_v = 3

ctrlpts_size_u = 300
ctrlpts_size_v = 300

surf = fitting.approximate_surface(points, size_u, size_v, degree_u, degree_v, ctrlpts_size_u= 20, ctrlpts_size_v= 20)
surf.evaluate()


# Plot the interpolated surface
surf.delta = 0.05
surf.vis = vis.VisSurface()
surf.render()

# # Visualize data and evaluated points together
import numpy as np
import matplotlib.pyplot as plt
evalpts = np.array(surf.evalpts)
#pts = np.array(points)
fig = plt.figure()
ax = plt.axes(projection='3d')
ax.scatter(evalpts[:, 0], evalpts[:, 1], evalpts[:, 2])
#ax.scatter(pts[:, 0], pts[:, 1], pts[:, 2], color="red")
plt.show()