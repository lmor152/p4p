import numpy as np

def line_projection(plane, img_point, F):
    t = plane[3]/(plane[0]*img_point[0] + plane[1]*img_point[1] + plane[2]*F)
    return t

def get_coord(img_point, F, t):
    x = img_point[0]*t
    y = img_point[1]*t
    z = F*t
    return [x, y, z]

def get_Local(world, v1, v2, centroid):
    x = np.dot(world - centroid, v1)
    y = np.dot(world - centroid, v2)
    return [x, y]

def projection(img, plane, v1, v2, centroid, F, cx, cy, asp):
    imsize = np.shape(img)
    tex = np.zeros(imsize[0] * imsize[1])
    point = np.zeros((imsize[0] * imsize[1], 2))
    count = 0
    for i in range(0, imsize[1]):
        for j in range(0, imsize[0]):
            img_point = [i-cx, (j-cy) * asp]
            t = line_projection(plane, img_point, F)
            tex[count] = img[j, i, 0]
            vec = get_coord(img_point, F, t)
            imgvec = get_Local(np.array(vec), v1, v2, centroid)
            point[count, :] = imgvec
            count = count + 1
    return tex, point 




