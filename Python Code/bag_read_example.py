#####################################################
##               Read bag from file                ##
#####################################################
stream = True
path = "C:\\Users\\liamm\\Documents\\Recordings\\"
fn = 'infrareds.bag'
#####################################################


import pyrealsense2 as rs
import numpy as np
import cv2
import argparse
import os.path

# Create object for parsing command-line options
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", type=str, help="Path to the bag file")
args = parser.parse_args(["-i",path+fn])

# Create pipeline
pipeline = rs.pipeline()
config = rs.config()
rs.config.enable_device_from_file(config, args.input)

# choose streams and their respective windows
config.enable_stream(rs.stream.infrared, 1)
config.enable_stream(rs.stream.infrared, 2)

cv2.namedWindow('IR Left', cv2.WINDOW_AUTOSIZE)
cv2.namedWindow('IR Right', cv2.WINDOW_AUTOSIZE)
# config.enable_stream(rs.stream.color)


# Start streaming from file
pipeline.start(config)
while stream:

    # Halt execution while we wait for frames
    frames = pipeline.wait_for_frames()

    # Get infrared stream from left camera
    ir1_frame = frames.get_infrared_frame(1)
    image1 = np.asanyarray(ir1_frame.get_data())
    cv2.imshow('IR Left', image1)

    # get infrared stream from right camera
    ir2_frame = frames.get_infrared_frame(2)
    image2 = np.asanyarray(ir2_frame.get_data())
    cv2.imshow('IR Right', image2)

    # exit when esc is pressed
    key = cv2.waitKey(1)
    if key == 27:
        cv2.destroyAllWindows()
        break

