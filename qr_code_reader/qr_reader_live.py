# import the necessary packages
from imutils.video import VideoStream
from pyzbar import pyzbar
import argparse
import datetime
import imutils
import time
import cv2

 
# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required=False,
	help="path to input image")
args = vars(ap.parse_args())

# use USB camera
#vs = VideoStream(src=0).start()
# use pi Camera 
vs = VideoStream(usePiCamera=True).start()

# using cv2 
#vs = cv2.VideoStream().start() 

time.sleep(2.0)

found = set()

print("[INFO] starting video stream...")

# loop over the frames from the video stream
while True:

    frame = vs.read()
    frame = imutils.resize(frame, width=400)

	# find the barcodes in the frame and decode each of the barcodes
    barcodes = pyzbar.decode(frame)
    # loop over the detected barcodes
    # loop over the detected barcodes
    for barcode in barcodes:
    # extract the bounding box location of the barcode and draw
    # the bounding box surrounding the barcode on the image
        (x, y, w, h) = barcode.rect
        cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 0, 255), 2)

        # the barcode data is a bytes object so if we want to draw it
        # on our output image we need to convert it to a string first
        barcodeData = barcode.data.decode("utf-8")
        barcodeType = barcode.type

        # draw the barcode data and barcode type on the image
        text = "{} ({})".format(barcodeData, barcodeType)
        cv2.putText(frame, text, (x, y - 10),
            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

        # if the barcode text is currently not in our CSV file, write
        # the timestamp + barcode to disk and update the set
        if barcodeData not in found:
            # csv.write("{},{}\n".format(datetime.datetime.now(), barcodeData))
            #csv.flush()
            found.add(barcodeData)
        # print the barcode type and data to the terminal
        print("[INFO] Found {} barcode: {}".format(barcodeType, barcodeData))


