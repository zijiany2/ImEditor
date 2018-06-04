import numpy as np
import os
import numpy.linalg as la
from math import ceil, floor
from scipy import misc, spatial
import time
import cv2

def wholePtsInTriangle(tri):
	'''
		collects all the points with interger coordinations inside a triangle
	'''
	minX = min (tri[0][0], tri[1][0], tri[2][0])
	maxX = max (tri[0][0], tri[1][0], tri[2][0])
	minY = min (tri[0][1], tri[1][1], tri[2][1])
	maxY = max (tri[0][1], tri[1][1], tri[2][1])
	ret = []
	for i in range(ceil(minX), ceil(maxX)):
		for j in range(ceil(minY), ceil(maxY)):
			A = [[tri[1][0] - tri[0][0],tri[2][0] - tri[0][0]],\
				 [tri[1][1] - tri[0][1],tri[2][1] - tri[0][1]]]
			b = [i - tri[0][0], j - tri[0][1]]
			coordinate = la.solve(A, b)
			if (coordinate[0] >=0 and coordinate[1] >=0 \
				and coordinate[0] + coordinate[1] <= 1):
				ret.append([i,j,1])
	return ret

def solveAffineTransform(tri1, tri2):
	'''
		compute the affine transformation from triangle 1 to triangle 2
	'''
	A = np.zeros((6,6))
	b = tri2.reshape(6)
	for i in range(3):
		j = 2*i
		A[j][0] = tri1[i][0]
		A[j][1] = tri1[i][1]
		A[j][2] = 1
		A[j+1][3] = tri1[i][0]
		A[j+1][4] = tri1[i][1]
		A[j+1][5] = 1
	x = la.solve(A, b)
	return x.reshape(2, 3)

def computeBilinear(inv1, im1):
	'''
		compute the pixel value of points inv1 using bilinear interpolation from image im1
	'''
	xf = min(floor(inv1[0]),len(im1)-1)
	yf = min(floor(inv1[1]),len(im1[0])-1)
	ix = inv1[0] - xf
	iy = inv1[1] - yf
	xc = min(xf+1, len(im1)-1)
	yc = min(yf+1, len(im1[0])-1)
	return (1-ix)*(1-iy)*im1[xf][yf] +\
		ix*(1-iy)*im1[xc][yf] +\
		(1-ix)*iy*im1[xf][yc] +\
		ix*iy*im1[xc][yc]


def avgIm(im1, im2, pts1, pts2, alpha):
	'''
		compute the morph result of two images with weight alpha and 1-alpha
	'''
	imout = np.zeros(im1.shape, dtype=np.int)
	pts_avg = alpha * pts1 + (1- alpha) * pts2
	tri = spatial.Delaunay(pts_avg)
	tri_pts = pts_avg[tri.simplices]
	tri_pts1 = pts1[tri.simplices]
	tri_pts2 = pts2[tri.simplices]
	for i in range(len(tri_pts)):
		transfrom1 = solveAffineTransform(tri_pts[i], tri_pts1[i])
		transfrom2 = solveAffineTransform(tri_pts[i], tri_pts2[i])
		insiders = wholePtsInTriangle(tri_pts[i])
		for insider in insiders:
			inv1 = np.dot(transfrom1, insider)
			inv2 = np.dot(transfrom2, insider)
			# print (insider)
			imout[insider[0]][insider[1]] = \
				(alpha * computeBilinear(inv1, im1) + \
				(1 - alpha) * computeBilinear(inv2, im2)).astype(int)
	imout = imout[1:imout.shape[0]-1, 1:imout.shape[1]-1]
	return imout

def avgIm3(im1, im2, im3, pts1, pts2, pts3):
	'''
		compute the morph result of three images 
	'''
	imout = np.zeros(im1.shape, dtype=np.int)
	pts_avg = 1/3 * pts1 + 1/3 * pts2 + 1/3 * pts3
	tri = spatial.Delaunay(pts_avg)
	tri_pts = pts_avg[tri.simplices]
	tri_pts1 = pts1[tri.simplices]
	tri_pts2 = pts2[tri.simplices]
	tri_pts3 = pts3[tri.simplices]
	for i in range(len(tri_pts)):
		transfrom1 = solveAffineTransform(tri_pts[i], tri_pts1[i])
		transfrom2 = solveAffineTransform(tri_pts[i], tri_pts2[i])
		transfrom3 = solveAffineTransform(tri_pts[i], tri_pts3[i])
		insiders = wholePtsInTriangle(tri_pts[i])
		for insider in insiders:
			inv1 = np.dot(transfrom1, insider)
			inv2 = np.dot(transfrom2, insider)
			inv3 = np.dot(transfrom3, insider)
			imout[insider[0]][insider[1]] = \
				(1/3* computeBilinear(inv1, im1) + \
				1/3 * computeBilinear(inv2, im2) + \
				1/3 * computeBilinear(inv3, im3)).astype(int)
	return imout
					
if __name__ == "__main__":
	imdir = 'detected_faces/'
	ptdir = 'keypoints/'
	resultdir = 'results/'

	im1 = misc.imread(imdir + '04.jpg')
	im2 = misc.imread(imdir + '05.jpg')
	im3 = misc.imread(imdir + '06.jpg')
	pts1 = np.loadtxt(ptdir + '04.txt', dtype='i', delimiter='\t')
	pts2 = np.loadtxt(ptdir + '05.txt', dtype='i', delimiter='\t')
	pts3 = np.loadtxt(ptdir + '06.txt', dtype='i', delimiter='\t')
	pts1[:,[0, 1]] = pts1[:,[1, 0]]
	pts2[:,[0, 1]] = pts2[:,[1, 0]]
	pts3[:,[0, 1]] = pts3[:,[1, 0]]
	imout = avgIm3(im1, im2, im3, pts1, pts2, pts3)
	misc.imsave('3combine.jpg', imout)

