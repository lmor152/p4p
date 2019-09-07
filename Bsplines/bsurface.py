from sklearn.decomposition import PCA

from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import matplotlib.pyplot as plt
import scipy 

from plyfile import PlyData
import numpy as np


mesh = PlyData.read('uniformptc.ply')
x = mesh.elements[0]['x']
y = mesh.elements[0]['y']
z = mesh.elements[0]['z']
points = np.c_[x, y, z]

pca = PCA(n_components=3)

pca.fit(points)

tpts = pca.transform(points)
tx = tpts[:, 0]
ty = tpts[:, 1]
tz = tpts[:, 2]

m = len(tx)
tck = scipy.interpolate.bisplrep(tx,ty,tz, task = 1, s = m-np.sqrt(2*m), eps= 100)
