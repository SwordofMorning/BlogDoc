#
# SPDX-FileCopyrightText: 2016-2022 Unisoc (Shanghai) Technologies Co., Ltd
# SPDX-License-Identifier: LicenseRef-Unisoc-General-1.0
#
# Copyright 2016-2022 Unisoc (Shanghai) Technologies Co., Ltd.
# Licensed under the Unisoc General Software License, version 1.0 (the License);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# https://www.unisoc.com/en_us/license/UNISOC_GENERAL_LICENSE_V1.0-EN_US
# Software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OF ANY KIND, either express or implied.
# See the Unisoc General Software License, version 1.0 for more details.
#

SPRD_LIB := libcamoem
SPRD_LIB += libispalg
SPRD_LIB += libcam_otp_parser
SPRD_LIB += libspcaftrigger
SPRD_LIB += libalRnBLV
ifeq ($(strip $(TARGET_BOARD_SENSOR_SS4C)),true)
SPRD_LIB += libremosaiclib
SPRD_LIB += libremosaic_wrapper
SPRD_LIB += libsprd_fcell_ss
endif

ifeq ($(strip $(TARGET_BOARD_SENSOR_OV4C)),true)
SPRD_LIB += libfcell
SPRD_LIB += libsprd_fcell
endif

SPRD_LIB += libcamcalitest
SPRD_LIB += libunnengine

PRODUCT_PACKAGES += $(SPRD_LIB)

PRODUCT_COPY_FILES += vendor/sprd/modules/libcamera/arithmetic/sprd_easy_hdr/param/sprd_hdr_tuning.param:vendor/etc/sprd_hdr_tuning.param
PRODUCT_COPY_FILES += vendor/sprd/modules/libcamera/arithmetic/sprd_gesture/firmware/gesture.mnn:vendor/firmware/gesture.mnn


ifneq ($(filter $(TARGET_BOARD_PLATFORM), ums9230), )
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/Sony/imx586,vendor/firmware/imx586) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/Sony/imx616,vendor/firmware/imx616) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/Sony/imx363_back_main,vendor/firmware/imx363_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/Samsung/s5kgw1sp03,vendor/firmware/s5kgw1sp03) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/OmniVision/ov08a10,vendor/firmware/ov08a10) \
                       $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/Samsung/s5kjn1,vendor/firmware/s5kjn1) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirl6/OmniVision/ov8856_back,vendor/firmware/ov8856_back)
endif

ifneq ($(filter $(TARGET_BOARD_PLATFORM), ums9620), )
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/Sony/imx586_replace_back_main,vendor/firmware/imx586_replace_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/Sony/imx616_front_main,vendor/firmware/imx616_front_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/OmniVision/ov08a10_back_tele,vendor/firmware/ov08a10_back_tele) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/OmniVision/ov8856_back_ultrawide,vendor/firmware/ov8856_back_ultrawide) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/Samsung/s5kgw1sp03_back_main,vendor/firmware/s5kgw1sp03_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/OmniVision/ov13855_back_main,vendor/firmware/ov13855_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/OmniVision/ov13855_back_slave,vendor/firmware/ov13855_back_slave) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/OmniVision/ov8856_front_dual,vendor/firmware/ov8856_front_dual) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6pro/OmniVision/ov08a10_back_sunny,vendor/firmware/ov08a10_back_sunny)
endif

ifneq ($(filter $(TARGET_BOARD_PLATFORM), ums9621), )
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6l/Sony/imx586_replace_back_main,vendor/firmware/imx586_replace_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6l/Sony/imx616_front_main,vendor/firmware/imx616_front_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6l/OmniVision/ov08a10_back_tele,vendor/firmware/ov08a10_back_tele) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6l/OmniVision/ov8856_back_ultrawide,vendor/firmware/ov8856_back_ultrawide) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6l/Samsung/s5kgw1sp03_back_main,vendor/firmware/s5kgw1sp03_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/qogirn6l/OmniVision/ov08a10_back_sunny,vendor/firmware/ov08a10_back_sunny)
endif

ifneq ($(filter $(TARGET_BOARD_PLATFORM), sp9863a), )
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/Sony/imx351,vendor/firmware/imx351) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/OmniVision/ov8856_shine_front,vendor/firmware/ov8856_shine_front) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/OmniVision/ov8856_shine_back,vendor/firmware/ov8856_shine_back) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/Galaxycore/gc08a3,vendor/firmware/gc08a3) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/Galaxycore/gc5035,vendor/firmware/gc5035) \
					  $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/OmniVision/ov5675_dual,vendor/firmware/ov5675_dual) \
					  $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/OmniVision/ov5675,vendor/firmware/ov5675) \
					  $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/OmniVision/ov8856_front_ts,vendor/firmware/ov8856_front_ts) \
					  $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/OmniVision/ov8856_back_ts,vendor/firmware/ov8856_back_ts) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/Samsung/s5k3p9sx04,vendor/firmware/s5k3p9sx04)\
					  $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl3/Samsung/s5k3p9sx04_ts,vendor/firmware/s5k3p9sx04_ts)
endif

$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/facebeauty/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/faceskinseg/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_fdr/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_portrait_scene/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_face_analyze/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_face_sdk/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_ai_sfnr/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_aidepth/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_raw_mfnr/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_portrait_seg/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/ips/3rdpool/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/iss2.0/PipelineLinkage/product.mk)
$(call inherit-product-if-exists, vendor/sprd/modules/libcamera/arithmetic/sprd_video_hdr/product.mk)

ifneq ($(filter $(TARGET_BOARD_PLATFORM), ums512), )
PRODUCT_COPY_FILES += vendor/sprd/modules/libcamera/arithmetic/sprd_easy_hdr/firmware/hdr_cadence.bin:vendor/firmware/hdr_cadence.bin \
                      vendor/sprd/modules/libcamera/arithmetic/sprd_warp/firmware/warp_cadence.bin:vendor/firmware/warp_cadence.bin \
                      vendor/sprd/modules/libcamera/arithmetic/libmfnr/firmware/mfnr_cadence.bin:vendor/firmware/mfnr_cadence.bin \
					  $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5pro/OmniVision/ov32a1q_back_main,vendor/firmware/ov32a1q_back_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5pro/Samsung/s5ks3p92_front_main,vendor/firmware/s5ks3p92_front_main) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5pro/OmniVision/ov16885_normal,vendor/firmware/ov16885_normal) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5pro/OmniVision/ov8856_shine,vendor/firmware/ov8856_shine)
endif

ifneq ($(filter $(TARGET_BOARD_PLATFORM), ums312), )
PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5/OmniVision/ov12a10,vendor/firmware/ov12a10) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5/OmniVision/ov5675_dual,vendor/firmware/ov5675_dual) \
                      $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/sensor/its_param/sharkl5/OmniVision/ov8856_shine,vendor/firmware/ov8856_shine)
endif


ifneq ($(wildcard $(LOCAL_PATH)/ips/topology/main//$(TARGET_BOARD_PLATFORM)),)

ifneq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)),)

IS_PRODUCT_JSON_DIRECTORY_EXIST := $(shell test -d $(LOCAL_PATH)/ips/topology/main/$(TARGET_BOARD_PLATFORM)/product/$(TARGET_BOARD_PLATFORM_PRODUCT) && echo yes)

#Determine whether the json directory of product exists or not
ifeq ($(IS_PRODUCT_JSON_DIRECTORY_EXIST),yes)

PIPELINE_PRODUCT_PATH := vendor/sprd/modules/libcamera/ips/topology/main/$(TARGET_BOARD_PLATFORM)/product/$(TARGET_BOARD_PLATFORM_PRODUCT)
pipeline_product_files := $(shell find $(PIPELINE_PRODUCT_PATH) -maxdepth 2 -type f -name *json)
PRODUCT_COPY_FILES += $(foreach file, $(pipeline_product_files), \
         $(file):/odm/etc/lwp/Topology/$(shell echo $(file)|awk -F '/' '{ print $$11 }')/$(shell echo $(file)|awk -F '/' '{ print $$12 }'))

endif

endif
PIPELINE_PATH := vendor/sprd/modules/libcamera/ips/topology/main/$(TARGET_BOARD_PLATFORM)/common
pipeline_files := $(shell find $(PIPELINE_PATH) -maxdepth 2 -type f -name *json)
PRODUCT_COPY_FILES += $(foreach file, $(pipeline_files), \
         $(file):/odm/etc/lwp/Topology/$(shell echo $(file)|awk -F '/' '{ print $$10 }')/$(shell echo $(file)|awk -F '/' '{ print $$11 }'))

include vendor/sprd/modules/libcamera/hal3_2v6/dispatch/framepolicy/policy_device.mk
endif
ifneq ($(wildcard $(LOCAL_PATH)/ips/icapcontrol//$(TARGET_BOARD_PLATFORM)),)
#PRODUCT_COPY_FILES += $(call find-copy-subdir-files,*,vendor/sprd/modules/libcamera/iss/icap_control/,/vendor/etc/icap)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/ips/icapcontrol/IcapSwitchs.xml:/vendor/etc/icap/control/IcapSwitchs.xml
ICAP_CONTROL_PATH := vendor/sprd/modules/libcamera/ips/icapcontrol/$(TARGET_BOARD_PLATFORM)/scenes
icap_control_files := $(shell find $(ICAP_CONTROL_PATH) -maxdepth 1 -type f -name *xml)
PRODUCT_COPY_FILES += $(foreach file, $(icap_control_files), \
         $(file):/vendor/etc/icap/control/$(shell echo $(file)|awk -F '/' '{ print $$8 }')/$(shell echo $(file)|awk -F '/' '{ print $$9 }'))
else
ifneq ($(wildcard $(LOCAL_PATH)/ips/icapcontrol/common),)
PRODUCT_COPY_FILES +=$(LOCAL_PATH)/ips/icapcontrol/IcapSwitchs.xml:/vendor/etc/icap/control/IcapSwitchs.xml
ICAP_CONTROL_PATH := vendor/sprd/modules/libcamera/ips/icapcontrol/common/scenes
icap_control_files := $(shell find $(ICAP_CONTROL_PATH) -maxdepth 1 -type f -name *xml)
PRODUCT_COPY_FILES += $(foreach file, $(icap_control_files), \
         $(file):/vendor/etc/icap/control/$(shell echo $(file)|awk -F '/' '{ print $$8 }')/$(shell echo $(file)|awk -F '/' '{ print $$9 }'))
endif
endif


