#camera sensor config
#PRODUCT_COPY_FILES += \
    $(call md-board-overlay,camera/zoom_config.json):$(TARGET_COPY_OUT_ODM)/etc/zoom_config.json

#camera sensor config
PRODUCT_COPY_FILES += \
    $(call md-board-overlay,camera/zoom_config.json):$(TARGET_COPY_OUT_ODM)/etc/zoom_config.json \
    $(ETC_FILES_DIR)/android.hardware.camera.manual_sensor.xml:$(TARGET_COPY_OUT_ODM)/etc/permissions/android.hardware.camera.manual_sensor.xml

#start camera configuration
#------section 1: software structure------
TARGET_BOARD_CAMERA_FUNCTION_DUMMY := false
TARGET_BOARD_SPRD_EXFRAMEWORKS_SUPPORT := true
#HAL1.0  HAL2.0  HAL3.0
TARGET_BOARD_CAMERA_HAL_VERSION := HAL3.2
#support 64bit isp
TARGET_BOARD_CAMERA_ISP_64BIT := true
# temp for isp3.0
TARGET_BOARD_CAMERA_ISP_VERSION := v2_9
TARGET_BOARD_IS_SC_FPGA := false
#camera offline structure
TARGET_BOARD_CAMERA_OFFLINE := true
#------section 2: sensor & flash config------
#camera auto detect sensor
TARGET_BOARD_CAMERA_AUTO_DETECT_SENSOR := true
#select camera 2M,3M,5M,8M,13M,16M,21M
CAMERA_SUPPORT_SIZE := s32
FRONT_CAMERA_SUPPORT_SIZE := s16
BACK_EXT_CAMERA_SUPPORT_SIZE := s16
FRONT_EXT_CAMERA_SUPPORT_SIZE := s8
BACK_EXT2_CAMERA_SUPPORT_SIZE := s8

#camera dual sensor
TARGET_BOARD_CAMERA_DUAL_SENSOR_MODULE := true
#dual camera 3A sync
#TARGET_BOARD_CONFIG_CAMERA_DUAL_SYNC := true
#sensor multi-instance
#TARGET_BOARD_CAMERA_SENSOR_MULTI_INSTANCE_SUPPORT := ture
TARGET_BOARD_CAMERA_SENSOR_MULTI_INSTANCE_SUPPORT := false
#camera sensor support list
#example
CAMERA_SENSOR_TYPE_BACK := ov13855,ov13855_dual
CAMERA_SENSOR_TYPE_FRONT := ov8856_front,ov8856_xl_front
CAMERA_SENSOR_TYPE_BACK_EXT := ov13855,ov13855_dual
CAMERA_SENSOR_TYPE_FRONT_EXT := ov8856_front,ov8856_xl_front


#tele
SENSOR_OV8856_TELE := true
#camera dual sensor
TARGET_BOARD_CAMERA_DUAL_SENSOR_MODULE := true
#tuning param support list
TUNING_PARAM_LIST := "ov13855_back_main,ov8856_back_ultrawide,ov13855_back_slave,ov8856_front_dual"
#4in1
TARGET_BOARD_CAMERA_4IN1 := true
#4in1 ov4c/ss4c
#TARGET_BOARD_SENSOR_OV4C := true
TARGET_BOARD_SENSOR_SS4C := true
#ams
#tof
TARGET_CAMERA_SENSOR_TOF := tof_vl53l0
#flash led  feature
TARGET_BOARD_CAMERA_FLASH_LED_0 := true # flash led0 config
TARGET_BOARD_CAMERA_FLASH_LED_1 := true # flash led1 config
#flash IC
TARGET_BOARD_CAMERA_FLASH_TYPE := ocp8137
#front flash type
#lcd,led,flash
TARGET_BOARD_FRONT_CAMERA_FLASH_TYPE := lcd
#Range of value 0~31
CAMERA_TORCH_LIGHT_LEVEL := 16
#PDAF feature
TARGET_BOARD_CAMERA_DCAM_PDAF := false
#TARGET_BOARD_CAMERA_PDAF_TYPE := 3
TARGET_BOARD_CAMERA_PDAF_TYPE := 0
#------section 3: feature config------
#select camera zsl cap mode
TARGET_BOARD_CAMERA_CAPTURE_MODE := false
ifneq ($(strip $(CMCC_PROJECT)),true)
#face detect
TARGET_BOARD_CAMERA_FACE_DETECT := true
#facedetect_HardWare_Support
TARGET_BOARD_FD_HW_SUPPORT := false
TARGET_BOARD_CAMERA_FD_MODULAR_KERNEL := fd2.0
#UCAM feature
TARGET_BOARD_CAMERA_FACE_BEAUTY := true
#face beauty vdsp
TARGET_BOARD_CAMERA_FB_VDSP_SUPPORT := true
#face detect version 0--old Algorithm library 1--new Algorithm library
TARGET_BOARD_SPRD_FD_VERSION := v1
#hdr capture
TARGET_BOARD_CAMERA_HDR_CAPTURE := true
TARGET_BOARD_CAMERA_SUPPORT_AUTO_HDR := true
#hdr version
TARGET_BOARD_SPRD_HDR_VERSION := v4
#BOKEH feature
TARGET_BOARD_BOKEH_MODE_SUPPORT := true
TARGET_BOARD_ARCSOFT_BOKEH_MODE_SUPPORT := false
TARGET_BOARD_BOKEH_CROP := true
#bokeh hdr feature
TARGET_BOARD_BOKEH_HDR_MODE_SUPPORT := true
#portrait
TARGET_BOARD_PORTRAIT_SUPPORT := true
#portrait_single
TARGET_BOARD_PORTRAIT_SINGLE_SUPPORT := true
#covered camera enble
TARGET_BOARD_COVERED_SENSOR_SUPPORT := false
#blur mode enble
TARGET_BOARD_BLUR_MODE_SUPPORT := true
endif
#3dnr capture
#TARGET_BOARD_CAMERA_3DNR_CAPTURE := true
#motionphone
TARGET_BOARD_CAMERA_MOTION_PHONE := true
#config capture size to 8M
TARGET_BOARD__DEFAULT_CAPTURE_SIZE_8M := true
#afbc enable
TARGET_BOARD_CAMERA_AFBC_ENABLE := false
#EIS
TARGET_BOARD_CAMERA_EIS := true
CAMERA_EIS_BOARD_PARAM := ums512-1
#GYRO
TARGET_BOARD_CAMERA_GYRO := true
#support auto anti-flicker
TARGET_BOARD_CAMERA_ANTI_FLICKER := false
#uv denoise
TARGET_BOARD_CAMERA_UV_DENOISE := false
#select continuous auto focus
TARGET_BOARD_CAMERA_CAF := false
#select camera support autofocus
TARGET_BOARD_CAMERA_AUTOFOCUS := false
#sprd cnr feature
TARGET_BOARD_CAMERA_CNR_CAPTURE = true
#support 3d face
TARGET_BOARD_3DFACE_SUPPORT := true
#supprt ai sence
TARGET_BOARD_CAMERA_AI := true
#support superwide
TARGET_BOARD_CAMERA_SUPPORT_ULTRA_WIDE := true
#Optics zoom
TARGET_BOARD_OPTICSZOOM_SUPPORT := true
#Multi Camera
TARGET_BOARD_MULTICAMERA_SUPPORT := true
#supprt auto tracking
TARGET_BOARD_CAMERA_AUTO_TRACKING := true
#faceid
#TARGET_BOARD_FACE_UNLOCK_SUPPORT := true
#TARGET_BOARD_DUAL_FACE_UNLOCK_SUPPORT := true
#TARGET_BOARD_3D_FACE_UNLOCK_SUPPORT := true

#video 60fps
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.video60fps.enable=1
#mfnr 5.0
TARGET_BOARD_SPRD_MFNR := v5
#slect mfnr version
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.mfnr.version=5
#fdr version
#TARGET_BOARD_SPRD_FDR_VERSION := v2
#NNA DDK version
TARGET_BOARD_NNA_DDK_VERSION := 3.12

#------section 4: optimize config------
#rotation capture
TARGET_BOARD_CAMERA_ROTATION_CAPTURE := false
TARGET_BOARD_FRONT_CAMERA_ROTATION := false
#image angle in different project
TARGET_BOARD_CAMERA_ADAPTER_IMAGE := d180
#pre_allocate capture memory
TARGET_BOARD_CAMERA_PRE_ALLOC_CAPTURE_MEM := false
#low capture memory
TARGET_BOARD_LOW_CAPTURE_MEM := true
#set camera recording frame rate dynamic
TARGET_BOARD_CONFIG_CAMRECORDER_DYNAMIC_FPS := false
#power optimization
TARGET_BOARD_CAMERA_POWER_OPTIMIZATION := false
#Slowmotion optimize
TARGET_BOARD_SPRD_SLOWMOTION_OPTIMIZE := true
#------section 5: other misc config------
#open dummy when camera hal not ready in bringup
TARGET_BOARD_CAMERA_FUNCTION_DUMMY := false
#MEET JPG 16 BIT ALIGNMENT
TARGET_BOARD_CAMERA_MEET_JPG_ALIGNMENT := true
#Adjust fps in range
TARGET_BOARD_ADJUST_FPS_IN_RANGE := true
#------section 6: kernel module config------
#use module for kernel driver or not
TARGET_BOARD_CAMERA_MODULAR := true
#modulars & version config
TARGET_BOARD_CAMERA_ISP_MODULAR_KERNEL := isp2.7
TARGET_BOARD_CAMERA_CPP_MODULAR_KERNEL := lite_r6p0
TARGET_BOARD_CAMERA_CPP_USER_DRIVER := true
TARGET_BOARD_CAMERA_SENSOR_MODULAR_KERNEL := yes
TARGET_BOARD_CAMERA_SENSOR_KERNEL_COMPAT := true
TARGET_BOARD_CAMERA_CSI_VERSION := r3p0
TARGET_BOARD_VDSP_MODULAR_KERNEL := cadence
TARGET_BOARD_CAMERA_BEAUTY_FOR_SHARKL5PRO := true
#frame control
TARGET_BOARD_CAMERA_FRAME_CONTROL := true
#frame state machine of capture policy
TARGET_BOARD_CAMERA_FRAME_STATE_MACHINE := false
#auto dc param offline only in frame state machine
TARGET_BOARD_CAMERA_AUTO_PARAM_OFFLINE := false
# ===============end of camera configuration ===============

#SUPPORT AUTO 3DNR
TARGET_BOARD_CAMERA_SUPPORT_AUTO_3DNR := true

#standby sensor that is not for preview
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.multiv2.sensorstandby=1
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.multiv2.sensorstandby.video=0
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.multi.video.max.zoom=18.0

#enable 3dnr & bokeh
PRODUCT_ODM_PROPERTIES += \
    persist.vendor.cam.3dnr.version=1 \
    persist.vendor.cam.ba.blur.version=6 \
    persist.vendor.cam.fr.blur.version=1 \
    persist.vendor.cam.api.version=0
#bokeh picture size
PRODUCT_ODM_PROPERTIES += \
   persist.vendor.cam.res.bokeh=RES_8M
#MMI main menu camera calibration & verification entry: 0-not display, 1-display
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.multicam.cali.veri=1
#MMI opticszoom calibration mode: 1-SW+W, 2-W+T, 3-SW+W+T
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.opticszoom.cali.mode=3
#set bokeh aux vcm
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.focus.distance=300
#enable beauty
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.facebeauty.corp=3
#enable cnr
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.cnr.mode=1
#enable ai
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.ai.scence.enable=2
#enable wt
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.wt.enable=0
#enable hdr_zsl
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.hdr.zsl=1
#multi camera
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.res.multi.camera=RES_MULTI
#mutli camera section
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.multi.section=3

#enable manual
PRODUCT_ODM_PROPERTIES += \
                              persist.sys.cam.manual.shutter=true \
                              persist.sys.cam.manual.focus=true

#enable camera app features
PRODUCT_ODM_PROPERTIES += \
                              persist.sys.cam.3dnr=false \
                              persist.sys.cam.beauty.fullfuc=true \
                              persist.sys.cam.wide.8M=true \
                              persist.sys.cam.wide.power=true
#enable 3d calibration
PRODUCT_ODM_PROPERTIES += persist.sys.3d.calibraion=1
PRODUCT_ODM_PROPERTIES += persist.sys.cam3.type=back_blur
PRODUCT_ODM_PROPERTIES += persist.sys.cam3.multi.cam.id=2

#ip feature list
#enable touch ev
PRODUCT_ODM_PROPERTIES += persist.sys.cam.touch.ev=true
#enable filter video
PRODUCT_ODM_PROPERTIES += persist.sys.cam.filtervideo.enable=true
#enable picture in picture
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.telwin.enable=0
#slect fdr verison
#PRODUCT_ODM_PROPERTIES += persist.vendor.cam.fdr.version=2
#select hdr version
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.hdr.version=4
TARGET_BOARD_CAMERA_MANUAL_SENSOR := true

#enable back portrait mode
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.ba.portrait.enable=0
#enable front portrait mode
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.fr.portrait.enable=0
#multi camera superwide & wide & tele
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.multi.camera.enable=1
#enable ultra wide
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.ultra.wide.enable=1
#enable video face beauty
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.video.face.beauty.enable=1
#shot2shot
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.fast.thumb=11111
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.shot2shot.enable=11
#slowmotion 960fps
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.slowmotion.960fps.enable=1
#enable autoDV videoblur
PRODUCT_ODM_PROPERTIES += persist.vendor.cam.autovideoblur.enable=1
