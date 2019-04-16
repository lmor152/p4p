#####################################################
##               Read bag from file                ##
#####################################################
stream = True
save = False
path = "..\\..\\Recordings\\"
fn = 'Gary.bag'
#fn = "Liam.bag"
streams = [ 
            'Color' 
            ,"Infrared1" 
            ,"Infrared2"
            ,'Depth'
        ]
#####################################################


import pyrealsense2 as rs
import numpy as np
import cv2
import argparse
import os.path
from datetime import datetime
import sys



# Create object for parsing command-line options
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", type=str, help="Path to the bag file")
args = parser.parse_args(["-i",path+fn])

# Create pipeline
pipeline = rs.pipeline()
config = rs.config()
rs.config.enable_device_from_file(config, args.input)

# choose streams and their respective windows
if "Infrared1" in streams:
    config.enable_stream(rs.stream.infrared, 1)
    cv2.namedWindow('IR Left', cv2.WINDOW_AUTOSIZE)

if "Infrared2" in streams:
    config.enable_stream(rs.stream.infrared, 2)
    cv2.namedWindow('IR Right', cv2.WINDOW_AUTOSIZE)

if save:
    timestamp = fn + str(datetime.now().strftime("%m-%d-%H%M%S"))
    timestamp = timestamp.replace(".bag", "-")
    os.makedirs("..\\..\\Frames\\" + timestamp)
    os.makedirs("..\\..\\Frames\\" + timestamp + "\\Infrared1")
    os.makedirs("..\\..\\Frames\\" + timestamp + "\\Infrared2")
    os.makedirs("..\\..\\Frames\\" + timestamp + "\\Color")
    os.makedirs("..\\..\\Frames\\" + timestamp + "\\Depth")

# Start streaming from file
profile = pipeline.start(config)
count = 0
device = profile.get_device()
playback = rs.playback(device)
playback.set_real_time(False)

try:
    while True:
        
        # Halt execution while we wait for frames
        frames = pipeline.wait_for_frames()

        # break at the end of the recording
        if frames.frame_number < count:
            cv2.destroyAllWindows()
            break
        
        count = frames.frame_number

        # Get infrared stream from left camera
        if "Infrared1" in streams:
            ir1_frame = frames.get_infrared_frame(1)
            image1 = np.asanyarray(ir1_frame.get_data())
            cv2.imshow('IR Left', image1)
            if save:
                cv2.imwrite("..\\..\\Frames\\" + timestamp + "\\Infrared1\\" + str(count) + ".png", image1)

        # get infrared stream from right camera
        if "Infrared2" in streams:
            ir2_frame = frames.get_infrared_frame(2)
            image2 = np.asanyarray(ir2_frame.get_data())
            cv2.imshow('IR Right', image2)
            if save:
                cv2.imwrite("..\\..\\Frames\\" + timestamp + "\\Infrared2\\" + str(count) + ".png", image2)

        # exit when esc is pressed
        key = cv2.waitKey(1)
        if key == 27:
            cv2.destroyAllWindows()
            break

finally:
    print(1/0)
    pass

raise SystemExit(0)
sys.exit()


