from pygigev import PyGigEV as gev

from pygigev import GevPixelFormat
from pygigev import color_conversions

import timeit
import cv2

# create new context to store native camera data
ctx = gev()

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

params = ctx.GevGetCameraInterfaceOptions()
print("Interface Params")
print(params)

ctx.GevSetFeatureValueAsString("ExposureTime", "5000")


# allocate image buffers and prepare for async image transfer to buffer
ctx.GevInitializeImageTransfer(10)

# start transfering images to memory buffer, use -1 for streaming or [1-9] for num frames 
ctx.GevStartImageTransfer(-1)

trying = False

gev_pix_format = params['format'][0]

color_convert = True

if gev_pix_format not in color_conversions:
    print("Conversion to bgr not supported for this format")
    color_convert = False

while(True):
    img = ctx.GevWaitForNextImage(1)
    if type(img) is int:
        if img == -6:
            continue
        else:
            break
    
    img = img.reshape(height, width) # is there a more efficient way to reshape?
    
    # convert to bgr
    if color_convert:
        img = cv2.cvtColor(img, color_conversions[gev_pix_format])
    
    cv2.imshow('pyGigE-V', img)
    key = cv2.waitKey(1) & 0xFF
    if key == ord('q'):
        break
    elif key == ord('s'):
        if trying:
            trying = False
            ctx.GevSetFeatureValueAsString("ExposureTime", "100")
        else:
            trying = True
            ctx.GevSetFeatureValueAsString("ExposureTime", "5000")
    
cv2.destroyAllWindows()

# Stop transfer, release memory, close camera connection 
ctx.GevStopImageTransfer()
ctx.GevAbortImageTransfer()
# ctx.GevReleaseImageBuffer() # not working at the moment, will need to exit python to release memory
ctx.GevCloseCamera()
