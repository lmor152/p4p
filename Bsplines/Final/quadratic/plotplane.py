
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


# create x,y
xx, yy = np.meshgrid(range(-80,100), range(-80,100))
zz = (plane[3] - plane[0] * xx - plane[1] * yy)/plane[2]

def line_projection(plane, img_point, F):
    t = (plane[3]/(plane[0]*img_point[0] + plane[1]*img_point[1] + plane[2]*F))
    return t
def get_coord(img_point, F, t):
    x = img_point[0]*t
    y = img_point[1]*t
    z = F*t
    return [x,y,z]

count = 0
proj_img = np.zeros([np.shape(image)[0]*np.shape(image)[1],3])
tex = np.zeros([np.shape(image)[0]*np.shape(image)[1],3])

import cv2
image = cv2.imread('../camparams/L.bmp')
for i in range(0,np.shape(image)[1]):
    for j in range(0,np.shape(image)[0]):
        img_point = [i-cx,j-cy]
        t = line_projection(plane, img_point, F)
        coord = get_coord(img_point, F, t)
        proj_img[count,:] = coord
        tex[count] = image[j,i,:]
        count = count + 1

'''
# plot the surface
plt3d = plt.figure().gca(projection='3d')
plt3d.plot_surface(xx, yy, zz)
plt3d.scatter(x,y,z)
plt3d.scatter(proj_img[0], )
plt.show()
'''