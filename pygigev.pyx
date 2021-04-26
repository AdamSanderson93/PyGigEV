import numpy as np
import cv2
import socket
import struct
from enum import Enum

cimport numpy as np
from cython cimport view
from cython.operator import dereference
from libc.stdlib cimport malloc, free
from posix.time cimport timeval

cimport decl

def ip2int(addr):
    return struct.unpack("!I", socket.inet_aton(addr))[0]


def int2ip(addr):
    return socket.inet_ntoa(struct.pack("!I", addr))

# cdef enum GevPixelFormat:
class GevPixelFormat(Enum):
    fmtMono8 = 0x01080001#, #/* 8 Bit Monochrome Unsigned */
    fmtMono8Signed = 0x01080002#, #/* 8 Bit Monochrome Signed*/
    fmtMono10 = 0x01100003#, #/* 10 Bit Monochrome Unsigned   */
    fmtMono10Packed = 0x010C0004#, #/* 10 Bit Monochrome Packed     */
    fmtMono12 = 0x01100005#, #/* 12 Bit Monochrome Unsigned   */
    fmtMono12Packed = 0x010C0006#, #/* 12 Bit Monochrome Packed     */
    fmtMono14 = 0x01100025#, #/* 14 Bit Monochrome Unsigned   */
    fmtMono16 = 0x01100007#, #/* 16 Bit Monochrome Unsigned   */
    fmtBayerGR8 = 0x01080008#, #/*  8-bit Bayer GR        */
    fmtBayerRG8 = 0x01080009#, #/*  8-bit Bayer RG        */
    fmtBayerGB8 = 0x0108000A#, #/*  8-bit Bayer GB        */
    fmtBayerBG8 = 0x0108000B#, #/*  8-bit Bayer BG        */
    fmtBayerGR10 = 0x0110000C#, #/* 10-bit Bayer GR        */
    fmtBayerRG10 = 0x0110000D#, #/* 10-bit Bayer RG        */
    fmtBayerGB10 = 0x0110000E#, #/* 10-bit Bayer GB        */
    fmtBayerBG10 = 0x0110000F#, #/* 10-bit Bayer BG        */
    fmtBayerGR10Packed = 0x010C0026#, #/* 10-bit Bayer GR packed */
    fmtBayerRG10Packed = 0x010C0027#, #/* 10-bit Bayer RG packed */
    fmtBayerGB10Packed = 0x010C0028#, #/* 10-bit Bayer GB packed */
    fmtBayerBG10Packed = 0x010C0029#, #/* 10-bit Bayer BG packed */
    fmtBayerGR12 = 0x01100010#, #/* 12-bit Bayer GR        */
    fmtBayerRG12 = 0x01100011#, #/* 12-bit Bayer RG        */
    fmtBayerGB12 = 0x01100012#, #/* 12-bit Bayer GB        */
    fmtBayerBG12 = 0x01100013#, #/* 12-bit Bayer BG        */
    fmtBayerGR12Packed = 0x010C002A#, #/* 12-bit Bayer GR packed */
    fmtBayerRG12Packed = 0x010C002B#, #/* 12-bit Bayer RG packed */
    fmtBayerGB12Packed = 0x010C002C#, #/* 12-bit Bayer GB packed */
    fmtBayerBG12Packed = 0x010C002D#, #/* 12-bit Bayer BG packed */
    fmtRGB8Packed = 0x02180014#, #/* 8 Bit RGB Unsigned in 24bits */
    fmtBGR8Packed = 0x02180015#, #/* 8 Bit BGR Unsigned in 24bits */
    fmtRGBA8Packed = 0x02200016#, #/* 8 Bit RGB Unsigned           */
    fmtBGRA8Packed = 0x02200017#, #/* 8 Bit BGR Unsigned           */
    fmtRGB10Packed = 0x02300018#, #/* 10 Bit RGB Unsigned          */
    fmtBGR10Packed = 0x02300019#, #/* 10 Bit BGR Unsigned          */
    fmtRGB12Packed = 0x0230001A#, #/* 12 Bit RGB Unsigned          */
    fmtBGR12Packed = 0x0230001B#, #/* 12 Bit BGR Unsigned          */
    fmtRGB14Packed = 0x0230005E#, #/* 14 Bit RGB Unsigned          */
    fmtBGR14Packed = 0x0230004A#, #/* 14 Bit BGR Unsigned          */
    fmtRGB16Packed = 0x02300033#, #/* 16 Bit RGB Unsigned          */
    fmtBGR16Packed = 0x0230004B#, #/* 16 Bit BGR Unsigned          */
    fmtRGBA16Packed= 0x02400064#, #/* 16 Bit RGBA Unsigned         */
    fmtBGRA16Packed= 0x02400051#, #/* 16 Bit BGRA Unsigned         */
    fmtRGB10V1Packed = 0x0220001C#, #/* 10 Bit RGB custom V1 (32bits)*/
    fmtRGB10V2Packed = 0x0220001D#, #/* 10 Bit RGB custom V2 (32bits)*/
    fmtYUV411packed = 0x020C001E#, #/* YUV411 (composite color) */
    fmtYUV422packed = 0x0210001F#, #/* YUV422 (composite color) */
    fmtYUV444packed = 0x02180020#, #/* YUV444 (composite color) */
    fmt_PFNC_YUV422_8 = 0x02100032#, #/* YUV 4:2:2 8-bit */
    fmtRGB8Planar = 0x02180021#, #/* RGB8 Planar buffers      */
    fmtRGB10Planar = 0x02300022#, #/* RGB10 Planar buffers     */
    fmtRGB12Planar = 0x02300023#, #/* RGB12 Planar buffers     */
    fmtRGB16Planar = 0x02300024#, #/* RGB16 Planar buffers     */
    fmt_PFNC_BiColorBGRG8 = 0x021000A6#, #/* Bi-color Blue/Green - Red/Green 8-bit */
    fmt_PFNC_BiColorBGRG10 = 0x022000A9#, #/* Bi-color Blue/Green - Red/Green 10-bit unpacked */
    fmt_PFNC_BiColorBGRG10p = 0x021400AA#, #/* Bi-color Blue/Green - Red/Green 10-bit packed */
    fmt_PFNC_BiColorBGRG12 = 0x022000AD#, #/* Bi-color Blue/Green - Red/Green 12-bit unpacked */
    fmt_PFNC_BiColorBGRG12p = 0x021800AE#, #/* Bi-color Blue/Green - Red/Green 12-bit packed */
    fmt_PFNC_BiColorRGBG8 = 0x021000A5#, #/* Bi-color Red/Green - Blue/Green 8-bit */
    fmt_PFNC_BiColorRGBG10  = 0x022000A7#, #/* Bi-color Red/Green - Blue/Green 10-bit unpacked */
    fmt_PFNC_BiColorRGBG10p = 0x021400A8#, #/* Bi-color Red/Green - Blue/Green 10-bit packed */
    fmt_PFNC_BiColorRGBG12  = 0x022000AB#, #/* Bi-color Red/Green - Blue/Green 12-bit unpacked */
    fmt_PFNC_BiColorRGBG12p = 0x021800AC #/* Bi-color Red/Green - Blue/Green 12-bit packed */

color_conversions = {
    GevPixelFormat.fmtMono8.value: cv2.COLOR_GRAY2BGR,
    GevPixelFormat.fmtBayerGR8.value: cv2.COLOR_BayerGR2RGB,
    GevPixelFormat.fmtBayerRG8.value: cv2.COLOR_BayerRG2RGB,
    GevPixelFormat.fmtBayerGB8.value: cv2.COLOR_BayerGB2RGB,
    GevPixelFormat.fmtBayerBG8.value: cv2.COLOR_BayerBG2RGB,
    GevPixelFormat.fmtRGB8Packed.value: cv2.COLOR_RGB2BGR,
    GevPixelFormat.fmtBGR8Packed.value: 0,
}


cdef class PyGigEV:
    cdef decl.GEV_CAMERA_INFO[1000] cameras
    cdef decl.GEV_CAMERA_HANDLE handle
    cdef decl.GEV_BUFFER_OBJECT* image_object_ptr
    cdef decl.UINT8[:, ::1] buffers
    cdef decl.UINT8 buffer_num
    cdef decl.UINT8 current_buf
    cdef decl.UINT8** buffers_ptr
    cdef decl.UINT32 width
    cdef decl.UINT32 height
    cdef decl.UINT32 pixel_size
    cdef decl.UINT32 x_offset
    cdef decl.UINT32 y_offset
    cdef decl.UINT32 format

    def __cinit__(self):
        self.handle = NULL
        self.width = 0
        self.height = 0
        self.x_offset = 0
        self.y_offset = 0
        self.format = 0
        self.pixel_size = 0

    def __init__(self):
        self.GevGetCameraList()

    def GevGetCameraList(self, int maxCameras=1000):
        cdef int numCameras
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevGetCameraList(self.cameras, maxCameras, &numCameras)
        return (self.handleExitCode(exitcode), numCameras)

    def GevOpenCamera(self, int gevAccessMode=4, int cameraListIndex=0):
        cdef decl.GEV_CAMERA_INFO _device = self.cameras[cameraListIndex]  # what happens with multiple cameras in list??
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevOpenCamera(&_device, <decl.GevAccessMode>gevAccessMode, &self.handle)
        return self.handleExitCode(exitcode)

    def GevOpenCameraByAddress(self, str ip_address, int gevAccessMode=4):
        cdef decl.UINT64 ip_adr = ip2int(ip_address)
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevOpenCameraByAddress(ip_adr, <decl.GevAccessMode>gevAccessMode, &self.handle)
        return self.handleExitCode(exitcode)
    
    def GevOpenCameraByName(self, char *name, int gevAccessMode=4):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevOpenCameraByName(name, <decl.GevAccessMode>gevAccessMode, &self.handle)
        return self.handleExitCode(exitcode)

    def GevOpenCameraBySN(self, char *sn, int gevAccessMode=4):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevOpenCameraBySN(sn, <decl.GevAccessMode>gevAccessMode, &self.handle)
        return self.handleExitCode(exitcode)

    def GevCloseCamera(self):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevCloseCamera(&self.handle)
        # free(self.buffers_ptr)
        return self.handleExitCode(exitcode)

    def GevGetCameraInterfaceOptions(self):
        cdef decl.GEV_CAMERA_OPTIONS options
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevGetCameraInterfaceOptions(self.handle, &options)
        return (self.handleExitCode(exitcode), options)

    def GevSetCameraInterfaceOptions(self, options):
        cdef decl.GEV_CAMERA_OPTIONS _options = options
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevSetCameraInterfaceOptions(self.handle, &_options)
        return self.handleExitCode(exitcode)

    def GevGetImageParameters(self):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevGetImageParameters(self.handle, &self.width, &self.height, &self.x_offset, &self.y_offset, &self.format)

        self.pixel_size = self.GetPixelSizeInBytes(self.format)
        
        return {'code': exitcode, 'width': self.width, 'height': self.height, 'x_offset': self.x_offset, 'y_offset': self.y_offset, 'pixelFormat':(self.format, hex(self.format))}

    def GevSetImageParameters(self, decl.UINT32 width, decl.UINT32 height, decl.UINT32 x_offset, decl.UINT32 y_offset, decl.UINT32 format):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevSetImageParameters(self.handle, width, height, x_offset, y_offset, format)
        return self.handleExitCode(exitcode)

    def GevInitImageTransfer(self, int bufferCyclingMode=1, int numImgBuffers=8):
        cdef decl.GEV_STATUS exitcode = 0
        imgParams = self.GevGetImageParameters()

        numImgBuffers += 1

        cdef decl.UINT32 size = self.GetPixelSizeInBytes(imgParams['pixelFormat'][0]) * \
                                imgParams['width'] * imgParams['height']

        # create variable to hold a image buffer
        self.buffers = np.empty(shape=[numImgBuffers,size], dtype=np.uint8, order="C")

        # create helper array to get a pointers
        self.buffers_ptr = <decl.UINT8**>malloc(numImgBuffers * sizeof(decl.UINT8*))
        
        # loop through buffer elements to addresses to store in helper array
        if not self.buffers_ptr: raise MemoryError
        try: 
            for i in range(numImgBuffers):
                self.buffers_ptr[i] = &self.buffers[i,0]

            exitcode = decl.GevInitImageTransfer(self.handle, <decl.GevBufferCyclingMode>bufferCyclingMode, numImgBuffers - 1, &self.buffers_ptr[0])
        except:
            pass

        self.buffer_num = numImgBuffers - 1
        self.current_buf = 0

        return self.handleExitCode(exitcode)

    def GevInitializeImageTransfer(self, int numImgBuffers=8):
        cdef decl.GEV_STATUS exitcode = 0
        imgParams = self.GevGetImageParameters()

        numImgBuffers += 1

        cdef decl.UINT32 size = self.GetPixelSizeInBytes(imgParams['pixelFormat'][0]) * \
                                imgParams['width'] * imgParams['height']

        # create variable to hold a image buffer
        self.buffers = np.empty(shape=[numImgBuffers,size], dtype=np.uint8, order="C")

        # create helper array to store image array pointers
        self.buffers_ptr = <decl.UINT8**>malloc(numImgBuffers * sizeof(decl.UINT8*))

        # loop through buffer elements to get addresses to store in helper array
        if not self.buffers_ptr: raise MemoryError
        try:
            for i in range(numImgBuffers):
                self.buffers_ptr[i] = &self.buffers[i,0]

            exitcode = decl.GevInitImageTransfer(self.handle, <decl.GevBufferCyclingMode>1, numImgBuffers - 1, self.buffers_ptr)
        except:
            pass

        self.buffer_num = numImgBuffers - 1
        self.current_buf = 0

        return self.handleExitCode(exitcode)

    def GevStartImageTransfer(self, int numFrames):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevStartImageTransfer(self.handle, <decl.UINT32>numFrames)
        return self.handleExitCode(exitcode)


    def GevWaitForNextImage(self, decl.UINT32 timeout=1000):
        cdef int size = self.height * self.width
        cdef view.array buffer_view = view.array(shape=(size,), itemsize=sizeof(decl.UINT8), format="c", mode="c", allocate_buffer=False)
        cdef decl.GEV_BUFFER_OBJECT* img
        cdef decl.GEV_STATUS exitcode = 0

        exitcode = decl.GevWaitForNextImage(self.handle, &img, timeout)

        if img is NULL or exitcode != decl.APIErrors.GEVLIB_OK:
            return exitcode
        
        buffer_view.data = <char *>img.address
        buff = np.asarray(buffer_view).view(np.uint8).copy()
        decl.GevReleaseImage(self.handle, img)
        decl.GevReleaseImageBuffer(self.handle, img.address)

        return buff

    # not working
    def GevStopImageTransfer(self):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevStopImageTransfer(self.handle)
        return self.handleExitCode(exitcode)

    # not working
    def GevAbortImageTransfer(self):
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevAbortImageTransfer(self.handle)
        return self.handleExitCode(exitcode)
    
    # havn't tested since previous 2 aren't working
    def GevReleaseImageBuffer(self):
        cdef decl.GEV_STATUS exitcode = 0
        for i in range(self.buffer_num):
            exitcode = decl.GevReleaseImageBuffer(self.handle, &self.buffers_ptr[i])
        return self.handleExitCode(exitcode)

    @staticmethod
    def GevApiInitialize():
        return decl.GevApiInitialize()
    
    @staticmethod
    def GevApiUninitialize():
        return decl.GevApiUninitialize()

    @staticmethod
    def GevGetLibraryConfigOptions():
        cdef decl.GEVLIB_CONFIG_OPTIONS options
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevGetLibraryConfigOptions(&options)
        return (exitcode, options)

    @staticmethod
    def GevSetLibraryConfigOptions(object options):
        cdef decl.GEVLIB_CONFIG_OPTIONS _options = options
        cdef decl.GEV_STATUS exitcode = 0
        exitcode = decl.GevGetLibraryConfigOptions(&_options)
        return exitcode

    @staticmethod
    def GevDeviceCount():
        return decl.GevDeviceCount()

    @staticmethod 
    def GetPixelSizeInBytes(int pixelFormat):
        return decl.GetPixelSizeInBytes(pixelFormat)

    @staticmethod 
    def GevGetPixelDepthInBits(int pixelFormat):
        return decl.GevGetPixelDepthInBits(pixelFormat)

    @staticmethod
    def handleExitCode(exitcode):
        if exitcode is not 0:
            return "Method returned code " + str(exitcode) + ", please check your camera's manual."
        else: return "OK"
    
    # ADDED!
    def GevSetFeatureValueAsString(self, feature, value):
        cdef decl.GEV_STATUS exitcode = 0
        cdef bytes py_bytes_f = feature.encode("ascii")
        cdef char* c_feature = py_bytes_f
        cdef bytes py_bytes_v = value.encode("ascii")
        cdef char* c_value = py_bytes_v

        exitcode = decl.GevSetFeatureValueAsString(self.handle,c_feature,c_value)

        return self.handleExitCode(exitcode)