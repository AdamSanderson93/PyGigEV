import pygigev
# from pygigev import PyGigEV as gev

import pygigev

import timeit
import cv2
from datetime import datetime
import os

print(pygigev.color_conversions)

# create new context to store native camera data
ctx = pygigev.PyGigEV()

# print list of available cameras
print(ctx.GevGetCameraList())

# open the first detected camera - returns 'OK'
ctx.GevOpenCamera()

# get image parameters - returns python object of params
params = ctx.GevGetImageParameters()
print("Initial image parameters:")
print(params)

# camera sensor properties
width_max = 1280
height_max = 1024
binning = 0
saturation = 0
brightness = 0
contrast = 0

# desired properties
crop_factor = 1.0
width = int(width_max * 1/crop_factor)
height = int(height_max * 1/crop_factor)
x_offset = int((width_max - width) / 2)
y_offset = int((height_max - height) / 2)

ctx.GevSetImageParameters(width, height, x_offset, y_offset, params['pixelFormat'][0])
params = ctx.GevGetImageParameters()
print("Final image parameters:")
print(params)

width = params['width']
height = params['height'] 

exposure = 5000

ctx.GevSetFeatureValueAsString("ExposureTime", str(exposure))


# allocate image buffers and prepare for async image transfer to buffer
ctx.GevInitializeImageTransfer(10)

# start transfering images to memory buffer, use -1 for streaming or [1-9] for num frames 
ctx.GevStartImageTransfer(-1)

trying = False

gev_pix_format = params['pixelFormat'][0]
color_convert = True

if gev_pix_format not in pygigev.color_conversions:
    print("Conversion to bgr not supported for this format")
    color_convert = False

params = ctx.GevGetCameraInterfaceOptions()
print("Interface Params")
print(params)


while True:
    img = ctx.GevWaitForNextImage(1)
    if type(img) is int:
        if img == -6:
            continue
        else:
            break
    
    img = img.reshape(height, width) # is there a more efficient way to reshape?

    # convert to bgr
    if color_convert:
        img = cv2.cvtColor(img, pygigev.color_conversions[gev_pix_format])
    
    cv2.imshow('pyGigE-V', img)
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        break
    elif key == ord('s'):
        cv2.imwrite(os.path.join(os.getcwd(),datetime.now().strftime("%m_%d_%Y_%H_%M_%S")+".png"), img)

    
cv2.destroyAllWindows()

# Stop transfer, release memory, close camera connection 
ctx.GevStopImageTransfer()
ctx.GevAbortImageTransfer()
# ctx.GevReleaseImageBuffer() # not working at the moment, will need to exit python to release memory
ctx.GevCloseCamera()
