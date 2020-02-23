import numpy as np
import optimisation as o
import BAquad as BA

# project texture to PCAP
def line_projection(plane, img_point, F):
    t = plane[3]/(plane[0]*img_point[0] + plane[1]*img_point[1] + plane[2]*F)
    return t

# get coordinates
def get_coord(img_point, F, t):
    x = img_point[0]*t
    y = img_point[1]*t
    z = F*t
    return [x, y, z]

# get local coordinates on PCAP plane
def get_Local(world, v1, v2, centroid):
    x = np.dot(world - centroid, v1)
    y = np.dot(world - centroid, v2)
    return [x, y]

# project image to PCAP
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

# get world coordinates from PCAP coordinates
def to_world(centroid, V, point):
    w = centroid + V[0,:]*point[0] + V[1,:]*point[1] + V[2,:]*point[2]
    return w
 
# forward project to model
def forward_project(fx, img, plane, v1, v2, centroid, xmin, xmax, ymin, ymax):
    F = fx[0,0]
    cx = fx[0,2]
    cy = fx[1,2]
    asp = F/fx[1,1]
    # project to PCAP
    tex, points =  projection(img, plane, v1, v2, centroid, F, cx, cy, asp)
    xlogic = (points[:,0] >= xmin) & (points[:,0] <= xmax)
    ylogic = (points[:,0] >= ymin) & (points[:,0] <= ymax)
    xypoints = points[xlogic & ylogic]
    texture = tex[xlogic & ylogic]
    worldpoints = np.c_[xypoints, np.zeros(len(xypoints))]
    origin = [np.dot(np.array([0,0,0]) - centroid, V[0,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[1,:]), 
        np.dot(np.array([0,0,0]) - centroid, V[2,:])]
    # get texturised surface
    proj = o.texture_coords(newPhi, xypoints, origin, xypoints, xgrid, ygrid, xyrange, d)
    texpoints = np.array(proj[:,0].tolist())

    return texpoints, texture

# objective function for optimisation
def map_obj(Phi, img, img2, plane, V, centroid, fx, xgrid, ygrid, xyrange, Rcam2, Tcam2):
    
    xmin, ymin = xyrange
    xmax = max(xgrid) + xmin
    ymax = max(ygrid) + ymin

    texpoints, texture = forward_project(fx, img, plane, V[0,:], V[1,:], centroid, xmin, xmax, ymin, ymax)

    xlogic = (texpoints[:,0] >= xmin) & (texpoints[:,0] <= xmax)
    ylogic = (texpoints[:,1] >= ymin) & (texpoints[:,1] <= ymax)
    cleanpoints = texpoints[xlogic & ylogic]
    cleantext = texture[xlogic & ylogic]

    texpointZ = BA.vevaluatePoint_Control_nonuni(d, cleanpoints[:,0], cleanpoints[:,1], xgrid, ygrid, xyrange, newPhi)
    texpoints3d = np.c_[cleanpoints, texpointZ]

    world_coord = np.zeros(np.shape(texpoints3d))
    for ind,i in enumerate(texpoints3d):
        world_coord[ind] = centroid + V[0,:]*i[0] + V[1,:]*i[1] + V[2,:]*i[2]
    
    from scipy.spatial.transform import Rotation as R
    r = R.from_rotvec(Rcam2)
    rotaionMatrix = r.as_dcm().T
    fmatrix = np.matmul(fx, np.matmul(np.c_[np.identity(3), np.zeros(3)], np.vstack([np.c_[rotaionMatrix, Tcam2], [0,0,0,1]])))
    
    ptc1 = np.c_[world_coord, np.ones(len(world_coord))]
    img = np.matmul(fmatrix, ptc1.T)
    image = img[0:2,:]
    image[0,:] = np.divide(img[0,:], img[2,:])
    image[1,:] = np.divide(img[1,:], img[2,:])
    image[1,:] = image[1,:] * asp

    nonuniform = image.T
    umin = int(np.floor(min(nonuniform[:,0])))
    umax = int(np.floor(max(nonuniform[:,0])))
    vmin = int(np.floor(min(nonuniform[:,1])))
    vmax = int(np.floor(max(nonuniform[:,1])))

    from sklearn.neighbors import NearestNeighbors
    knn = NearestNeighbors(n_neighbors=5)
    knn.fit(nonuniform)
    D, Ind = knn.kneighbors(Y)

    newtext = np.zeros(len(Ind))
    for i in range(0, len(Ind)):
        newtext[i] = np.dot(D[i,:], cleantext[Ind[i,:]]) / sum(D[i,:])

    IMG = np.zeros((len(range(vmin, vmax + 1)), len(range(umin, umax+1))))
    for i in range(0,len(Y)):
        IMG[Y[i,1] - vmin, Y[i,0] - umin] = newtext[i]
    IMG = IMG.astype(np.uint8)

    from skimage.measure import compare_ssim
    score = compare_ssim(IMG, img2[vmin:vmax+1, umin:umax+1, 1])
    
    return score






