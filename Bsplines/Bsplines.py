from plyfile import PlyData
import numpy as np

from geomdl import fitting
from geomdl.visualization import VisMPL as vis


# Data set
points = ((-5, -5, 0), (-2.5, -5, 0), (0, -5, 0), (2.5, -5, 0), (5, -5, 0), (7.5, -5, 0), (10, -5, 0),
          (-5, 0, 3), (-2.5, 0, 3), (0, 0, 3), (2.5, 0, 3), (5, 0, 3), (7.5, 0, 3), (10, 0, 3),
          (-5, 5, 0), (-2.5, 5, 0), (0, 5, 0), (2.5, 5, 0), (5, 5, 0), (7.5, 5, 0), (10, 5, 0),
          (-5, 7.5, -3), (-2.5, 7.5, -3), (0, 7.5, -3), (2.5, 7.5, -3), (5, 7.5, -3), (7.5, 7.5, -3), (10, 7.5, -3),
          (-5, 10, 0), (-2.5, 10, 0), (0, 10, 0), (2.5, 10, 0), (5, 10, 0), (7.5, 10, 0), (10, 10, 0))

mesh = PlyData.read('test_mouth.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]
points = tuple(map(tuple, points))

size_u = 5
size_v = 7
degree_u = 2
degree_v = 3

# Do global surface interpolation
surf = fitting.interpolate_surface(points, size_u, size_v, degree_u, degree_v)

# Plot the interpolated surface
surf.delta = 0.05
surf.vis = vis.VisSurface()
surf.render()


# # Visualize data and evaluated points together
import numpy as np
import matplotlib.pyplot as plt
evalpts = np.array(surf.evalpts)
pts = np.array(points)
fig = plt.figure()
ax = plt.axes(projection='3d')
ax.scatter(evalpts[:, 0], evalpts[:, 1], evalpts[:, 2])
ax.scatter(pts[:, 0], pts[:, 1], pts[:, 2], color="red")
plt.show()