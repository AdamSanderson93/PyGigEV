import numpy as np
cimport numpy as np
from posix.time cimport timeval
from libc cimport stdint


ctypedef int8_t INT8
ctypedef uint8_t UINT8
ctypedef int16_t INT16
ctypedef uint16_t UINT16
ctypedef bint BOOL
ctypedef int32_t INT32
ctypedef uint32_t UINT32
ctypedef int64_t INT64
ctypedef uint64_t UINT64

ctypedef UINT8* PUINT8
ctypedef UINT32* PUINT32

ctypedef int GEV_STATUS

ctypedef struct GEVLIB_CONFIG_OPTIONS:
    UINT32 version
    UINT32 logLevel
    UINT32 numRetries
    UINT32 command_timeout_ms
    UINT32 discovery_timeout_ms
    UINT32 enumeration_port
    UINT32 gvcp_port_range_start
    UINT32 gvcp_port_range_end

# // Buffer object structure
ctypedef struct GEV_BUFFER_OBJECT:
    UINT32 payload_type
    UINT32 state
    INT32 status
    UINT32 timestamp_hi
    UINT32 timestamp_lo
    UINT64 timestamp
    UINT64 recv_size
    UINT64 id
    UINT32 h
    UINT32 w
    UINT32 x_offset
    UINT32 y_offset
    UINT32 x_padding
    UINT32 y_padding
    UINT32 d
    UINT32 format
    PUINT8 address
    PUINT8 chunk_data
    UINT32 chunk_size
    char filename[256]

ctypedef GEV_CAMERA_INFO* PGEV_CAMERA_INFO

ctypedef void* GEV_CAMERA_HANDLE

ctypedef enum GevAccessMode:
    GevMonitorMode = 0 
    GevControlMode = 2
    GevExclusiveMode = 4

# // Buffer cycling control definition
ctypedef enum GevBufferCyclingMode:
    Asynchronous = 0
    SynchronousNextEmpty = 1 

ctypedef enum APIErrors:
    GEVLIB_OK = 0
    GEVLIB_ERROR_GENERIC = -1   #// Generic Error. A catch-all for unexpected behaviour.
    GEVLIB_ERROR_NULL_PTR = -2   #// NULL pointer passed to function or the result of a cast operation
    GEVLIB_ERROR_ARG_INVALID = -3        #// Passed argument to a function is not valid                                                               
    GEVLIB_ERROR_INVALID_HANDLE = -4        #// Invalid Handle
    GEVLIB_ERROR_NOT_SUPPORTED = -5   #// This version of hardware/fpga does not support this feature
    GEVLIB_ERROR_TIME_OUT = -6   #// Timed out waiting for a resource
    GEVLIB_ERROR_NOT_IMPLEMENTED = -10  #// Function / feature is not implemented.
    GEVLIB_ERROR_NO_CAMERA = -11  #// The action can't be execute because the camera is not connected.
    GEVLIB_ERROR_INVALID_PIXEL_FORMAT = -12  #// Pixel Format is invalid (not supported or not recognized)
    GEVLIB_ERROR_PARAMETER_INVALID = -13  #// Passed Parameter (could be inside a data structure) is invalid/out of range.
    GEVLIB_ERROR_SOFTWARE = -14  #// software error, unexpected result
    GEVLIB_ERROR_API_NOT_INITIALIZED = -15  #// API has not been initialized
    GEVLIB_ERROR_DEVICE_NOT_FOUND = -16  #// Device/camera specified was not found.
    GEVLIB_ERROR_ACCESS_DENIED = -17  #// API will not access the device/camera/feature in the specified manner.
    GEVLIB_ERROR_NOT_AVAILABLE = -18  #// Feature / function is not available for access (but is implemented).
    GEVLIB_ERROR_NO_SPACE = -19  #// The data being written to a feature is too large for the feature to store.
    GEVLIB_ERROR_XFER_NOT_INITIALIZED = -20  #// Payload transfer is not initialized but is required to be for this function.
    GEVLIB_ERROR_XFER_ACTIVE = -21  #// Payload transfer is active but is required to be inactive for this function.
    GEVLIB_ERROR_XFER_NOT_ACTIVE = -22  #// Payload transfer is not active but is required to be active for this function.


ctypedef struct GEV_CAMERA_OPTIONS:
    UINT32 numRetries
    UINT32 command_timeout_ms
    UINT32 heartbeat_timeout_ms
    UINT32 streamPktSize            #// GVSP max packet size ( less than or equal to MTU size).
    UINT32 streamPktDelay            #// Delay between packets (microseconds) - to tune packet pacing out of NIC.
    UINT32 streamNumFramesBuffered    #// # of frames to buffer (min 2)
    UINT32 streamMemoryLimitMax        #// Maximum amount of memory to use (puts an upper limit on the # of frames to buffer).
    UINT32 streamMaxPacketResends    #// Maximum number of packet resends to allow for a frame (defaults to 100).
    UINT32 streamFrame_timeout_ms    #// Frame timeout (msec) after leader received.
    INT32  streamThreadAffinity        #// CPU affinity for streaming thread (marshall/unpack/write to user buffer) - default handling is "-1" 
    INT32  serverThreadAffinity        #// CPU affinity for packet server thread (recv/dispatch) - default handling is "-1"
    UINT32 msgChannel_timeout_ms
    UINT32 enable_passthru_mode

cdef extern from "gevapi.h":

    ctypedef struct GEV_NETWORK_INTERFACE:
        BOOL fIPv6
        UINT32 ipAddr
        UINT32 ipAddrLow
        UINT32 ipAddrHigh
        UINT32 ifIndex

    ctypedef struct GEV_CAMERA_INFO:
        BOOL fIPv6
        UINT32 ipAddr
        UINT32 ipAddrLow
        UINT32 ipAddrHigh
        UINT32 macLow
        UINT32 macHigh
        GEV_NETWORK_INTERFACE host
        UINT32 capabilities
        char[65] manufacturer
        char[65] model
        char[65] serial
        char[65] version
        char[65] username

    # //====================================================================
    # // Public API
    # //====================================================================
    # // API Initialization
    GEV_STATUS GevApiInitialize()
    GEV_STATUS GevApiUninitialize()

    # //====================================================================
    # // API Configuratoin options
    GEV_STATUS GevGetLibraryConfigOptions(GEVLIB_CONFIG_OPTIONS* options)
    GEV_STATUS GevSetLibraryConfigOptions(GEVLIB_CONFIG_OPTIONS* options)

    # //=================================================================================================
    # // Camera automatic discovery
    int GevDeviceCount()
    GEV_STATUS GevGetCameraList(GEV_CAMERA_INFO* cameras, int maxCameras, int* numCameras)

    # GEV_STATUS GevForceCameraIPAddress( UINT32 macHi, UINT32 macLo, UINT32 IPAddress, UINT32 subnetmask);
    # GEV_STATUS GevEnumerateNetworkInterfaces(GEV_NETWORK_INTERFACE *pIPAddr, UINT32 maxInterfaces, PUINT32 pNumInterfaces );

    # //=================================================================================================
    # // Utility function (external) for discovering camera devices.  
    # GEV_STATUS GevEnumerateGevDevices(GEV_NETWORK_INTERFACE *pIPAddr, UINT32 discoveryTimeout, GEV_DEVICE_INTERFACE *pDevice, UINT32 maxDevices, PUINT32 pNumDevices );

    # // Camera Manual discovery/setup 
    # GEV_STATUS GevSetCameraList( GEV_CAMERA_INFO *cameras, int numCameras); // Manually set camera list from data structure.

    # //=================================================================================================
    # // Gige Vision Camera Access
    GEV_STATUS GevOpenCamera(GEV_CAMERA_INFO* device, GevAccessMode mode, GEV_CAMERA_HANDLE* handle)
    GEV_STATUS GevOpenCameraByAddress( unsigned long ip_address, GevAccessMode mode, GEV_CAMERA_HANDLE *handle)
    GEV_STATUS GevOpenCameraByName( char *name, GevAccessMode mode, GEV_CAMERA_HANDLE *handle)
    GEV_STATUS GevOpenCameraBySN( char *sn, GevAccessMode mode, GEV_CAMERA_HANDLE *handle)

    GEV_STATUS GevCloseCamera(GEV_CAMERA_HANDLE* handle)

    # GEV_CAMERA_INFO *GevGetCameraInfo( GEV_CAMERA_HANDLE handle);

    GEV_STATUS GevGetCameraInterfaceOptions(GEV_CAMERA_HANDLE handle, GEV_CAMERA_OPTIONS* options)
    GEV_STATUS GevSetCameraInterfaceOptions(GEV_CAMERA_HANDLE handle, GEV_CAMERA_OPTIONS* options)

    # //=================================================================================================
    # // Manual GigeVision access to GenICam XML File
    # GEV_STATUS Gev_RetrieveXMLData( GEV_CAMERA_HANDLE handle, int size, char *xml_data, int *num_read, int *data_is_compressed );
    # GEV_STATUS Gev_RetrieveXMLFile( GEV_CAMERA_HANDLE handle, char *file_name, int size, BOOL force_download );

    # //=================================================================================================
    # // GenICam XML Feature Node Map manual registration/access functions (for use in C++ code).
    # GEV_STATUS GevConnectFeatures(  GEV_CAMERA_HANDLE handle,  void *featureNodeMap);
    # void * GevGetFeatureNodeMap(  GEV_CAMERA_HANDLE handle);

    # //=================================================================================================
    # // GenICam XML Feature access functions (C language compatible).
    # GEV_STATUS GevGetGenICamXML_FileName( GEV_CAMERA_HANDLE handle, int size, char *xmlFileName);
    # GEV_STATUS GevInitGenICamXMLFeatures( GEV_CAMERA_HANDLE handle, BOOL updateXMLFile);
    # GEV_STATUS GevInitGenICamXMLFeatures_FromFile( GEV_CAMERA_HANDLE handle, char *xmlFileName);
    # GEV_STATUS GevInitGenICamXMLFeatures_FromData( GEV_CAMERA_HANDLE handle, int size, void *pXmlData);

    # GEV_STATUS GevGetFeatureValue( GEV_CAMERA_HANDLE handle, const char *feature_name, int *feature_type, int value_size, void *value);
    # GEV_STATUS GevSetFeatureValue( GEV_CAMERA_HANDLE handle, const char *feature_name, int value_size, void *value);
    GEV_STATUS GevSetFeatureValueAsString( GEV_CAMERA_HANDLE handle, const char *feature_name, const char *value_string);

    # //=================================================================================================
    # // Camera image acquisition
    GEV_STATUS GevGetImageParameters(GEV_CAMERA_HANDLE handle, PUINT32 width, PUINT32 height, PUINT32 x_offset, PUINT32 y_offset, PUINT32 format)
    GEV_STATUS GevSetImageParameters(GEV_CAMERA_HANDLE handle,UINT32 width, UINT32 height, UINT32 x_offset, UINT32 y_offset, UINT32 format)
    GEV_STATUS GevInitImageTransfer( GEV_CAMERA_HANDLE handle, GevBufferCyclingMode mode, UINT32 numBuffers, UINT8 **bufAddress)
    GEV_STATUS GevInitializeImageTransfer( GEV_CAMERA_HANDLE handle, UINT32 numBuffers, UINT8 **bufAddress)
    GEV_STATUS GevFreeImageTransfer( GEV_CAMERA_HANDLE handle)
    GEV_STATUS GevStartImageTransfer(GEV_CAMERA_HANDLE handle, int numFrames)
    GEV_STATUS GevStopImageTransfer(GEV_CAMERA_HANDLE handle)
    GEV_STATUS GevAbortImageTransfer( GEV_CAMERA_HANDLE handle)

    # GEV_STATUS GevQueryImageTransferStatus( GEV_CAMERA_HANDLE handle, PUINT32 pTotalBuffers, PUINT32 pNumUsed, PUINT32 pNumFree, PUINT32 pNumTrashed, GevBufferCyclingMode *pMode);
    int GetPixelSizeInBytes(UINT32 pixelType)

    GEV_STATUS GevResetImageTransfer( GEV_CAMERA_HANDLE handle );

    GEV_STATUS GevGetNextImage(GEV_CAMERA_HANDLE handle, GEV_BUFFER_OBJECT** image_object_ptr, UINT32 timeout)
    GEV_STATUS GevGetImageBuffer( GEV_CAMERA_HANDLE handle, void** image_buffer)
    GEV_STATUS GevWaitForNextImageBuffer(GEV_CAMERA_HANDLE handle, void** image_buffer, UINT32 timeout)
    GEV_STATUS GevWaitForNextImage( GEV_CAMERA_HANDLE handle, GEV_BUFFER_OBJECT** image_object, UINT32 timeout)
    GEV_STATUS GevReleaseImage(GEV_CAMERA_HANDLE handle,GEV_BUFFER_OBJECT *image_object_ptr)
    GEV_STATUS GevReleaseImageBuffer( GEV_CAMERA_HANDLE handle, void *image_buffer_ptr)

    # //=================================================================================================
    # // Camera event handling
    # GEV_STATUS GevRegisterEventCallback(GEV_CAMERA_HANDLE handle,  UINT32 EventID, GEVEVENT_CBFUNCTION func, void *context);
    # GEV_STATUS GevRegisterApplicationEvent(GEV_CAMERA_HANDLE handle,  UINT32 EventID, _EVENT appEvent);
    # GEV_STATUS GevUnregisterEvent(GEV_CAMERA_HANDLE handle,  UINT32 EventID);


    BOOL GevIsPixelTypeMono( UINT32 pixelType)
    BOOL GevIsPixelTypeRGB( UINT32 pixelType)
    BOOL GevIsPixelTypeCustom( UINT32 pixelType)
    BOOL GevIsPixelTypePacked( UINT32 pixelType)
    # UINT32 GevGetPixelSizeInBytes( UINT32 pixelType);
    UINT32 GevGetPixelDepthInBits(UINT32 pixelType)
    # UINT32 GevGetRGBPixelOrder( UINT32 pixelType);
    # GEVLIB_STATUS GevTranslateRawPixelFormat( UINT32 rawFormat, PUINT32 translatedFormat, PUINT32 bitDepth, PUINT32 order);
    # const char *GevGetFormatString( UINT32 format);

