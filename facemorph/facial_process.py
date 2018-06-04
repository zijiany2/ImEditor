import numpy as np
import argparse
import dlib
import cv2
import os

def getCoordinates(keypoints):
	coords = np.zeros((68, 2), dtype="int")
	for i in range(0, 68):
		coords[i] = (keypoints.part(i).x, keypoints.part(i).y)
	return coords

def reserve_margin(image, x, y, w, h):
	(height, width) = image.shape[:2]
	x = max(0, int(x - 0.1*w))
	y = max(0, int(y - 0.4*h))
	w = min(width, int(1.2*w))
	h = min(height, int(1.5*h))
	return (x,y,w,h)

def resize(image, new_width, new_height = None):
	(h, w) = image.shape[:2]
	width = new_width
	r = width / float(w)
	height = int(h * r) if not new_height else new_height
	dim = (width, height)
	image = cv2.resize(image, dim, interpolation=cv2.INTER_AREA)
	return image

ap = argparse.ArgumentParser()
ap.add_argument("-r", "--recursive", required=True, help="input image folder path")
args = vars(ap.parse_args())

detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")

for filename in os.listdir(args["recursive"]):
	prefix = (filename.split("."))[0]
	output_file = open("./keypoints/" + prefix + ".txt", 'w')
	print (filename)
	
	image = cv2.imread(args["recursive"] + "/" + filename)
	if image is None:
		continue

	image = resize(image, 500)
	gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

	face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
	faces = face_cascade.detectMultiScale(gray)
	x, y, w, h = faces[0]
	x, y, w, h = reserve_margin(image, x, y, w, h)


	image = image[y:y+h, x:x+w]
	image = resize(image, 320, 400)
	cv2.imwrite("./detected_faces/" + prefix + ".jpg", image)

	gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

	# detect faces in the grayscale image
	rects = detector(gray, 1)
	# loop over the face detections
	(h, w, _) = image.shape
	output_file.write("%d\t%d\n" %(w-1, h-1))
	output_file.write("%d\t%d\n" %(0, h-1))
	output_file.write("%d\t%d\n" %(w-1, 0))
	output_file.write("%d\t%d\n" %(0, 0))

	# Draw Triangle

	for (i, rect) in enumerate(rects):
		keypoints = predictor(gray, rect)
		keypoints = getCoordinates(keypoints)
		for (x, y) in keypoints:
			output_file.write("%d\t%d\n" %(x, y))
	output_file.close()
