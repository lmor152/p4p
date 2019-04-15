import pyrealsense2 as rs
import numpy as np
import cv2
import argparse
import os.path


################################

resx = 1280
resy = 720
format = rs.format.y8
fps = 30

################################

pipeline = rs.pipeline()
config = rs.config()


parser = argparse.ArgumentParser(description="Read recorded bag file and display depth stream in jet colormap.\
                                Remember to change the stream resolution, fps and format to match the recorded.")
parser.add_argument("-i", "--input", type=str, help="Path to the bag file")
args = parser.parse_args(["-i","C:\\Users\\liamm\\Documents\\Recordings\\Everything.bag"])
#rs.config.enable_device_from_file(config, args.input)


config.enable_stream(rs.stream.infrared,1, resx, resy, format, fps)
# config.enable_stream(rs.stream.infrared, 2)
profile = pipeline.start(config)

try:
    while True:
        frames = pipeline.wait_for_frames()

        ir1_frame = frames.get_infrared_frame(1)
        image1 = np.asanyarray(ir1_frame.get_data())
        cv2.namedWindow('IR Left', cv2.WINDOW_AUTOSIZE)
        cv2.imshow('IR Left', image1)
        

        # ir2_frame = frames.get_infrared_frame(2)
        # image2 = np.asanyarray(ir2_frame.get_data())
        # cv2.namedWindow('IR Right', cv2.WINDOW_AUTOSIZE)
        # cv2.imshow('IR Right', image2)

        key = cv2.waitKey(1)
        # Press esc or 'q' to close the image window
        if key & 0xFF == ord('q') or key == 27:
            cv2.destroyAllWindows()
            break
finally:
    pipeline.stop()