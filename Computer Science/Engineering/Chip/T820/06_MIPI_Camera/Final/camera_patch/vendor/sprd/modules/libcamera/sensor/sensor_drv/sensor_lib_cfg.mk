#
# SPDX-FileCopyrightText: 2019-2022 Unisoc (Shanghai) Technologies Co., Ltd
# SPDX-License-Identifier: LicenseRef-Unisoc-General-1.0
#
# Copyright 2019-2022 Unisoc (Shanghai) Technologies Co., Ltd.
# Licensed under the Unisoc General Software License, version 1.0 (the License);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# https://www.unisoc.com/en_us/license/UNISOC_GENERAL_LICENSE_V1.0-EN_US
# Software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OF ANY KIND, either express or implied.
# See the Unisoc General Software License, version 1.0 for more details.
#

PRODUCT_PACKAGES += libsensor_imx351 \
    libsensor_ov5675_dual \
    libsensor_ov7251 \
    libsensor_ov8856_shine \
    libsensor_ov8856_shine_front \
    libsensor_imx362 \
    libsensor_ov5675 \
    libsensor_ov7251 \
    libsensor_ov7251_dual \
    libsensor_s5k3p9sx04 \
    libsensor_s5k4h9yx \
    libsensor_s5k5e9yu05 \
    libsensor_ov32a1q \
    libsensor_ov16885_normal \
    libsensor_imx363 \
    libsensor_imx258 \
    libsensor_imx582 \
    libsensor_imx586 \
    libsensor_imx586_2lane \
    libsensor_ov13855 \
    libsensor_ov13855_dual \
    libsensor_ov13b10 \
    libsensor_s5k3l8xxm3 \
    libsensor_s5k4h8yx \
    libsensor_ov2680 \
    libsensor_ov8858 \
    libsensor_s5k5e8yx \
    libsensor_gc2375 \
    libsensor_gc2145 \
    libsensor_s5k3l6xx03 \
    libsensor_s5k4h7 \
    libsensor_gc5035 \
    libsensor_s5k3l6 \
    libsensor_s5k3l6_cy \
    libsensor_gc2375h \
    libsensor_hi846_wide \
    libsensor_hi846 \
    libsensor_ov2680 \
    libsensor_gc2375_js_2 \
    libsensor_gc2385_wj_1 \
    libsensor_hi846_gj_1 \
    libsensor_hi1336_m0 \
    libsensor_hi1336_s0 \
    libsensor_gc02m1b_js_1 \
    libsensor_ov13853_m1 \
    libsensor_ov13853_s1 \
    libsensor_gc8034_gj_2 \
    libsensor_gc2375_wj_2 \
    libsensor_ov12a10 \
    libsensor_ov08a10 \
    libsensor_ov08a10_back \
    libsensor_ov08a10_hisense \
    libsensor_ov8856_front \
    libsensor_ov8856_back \
    libsensor_imx616 \
    libsensor_imx616_2lane \
    libsensor_ov02a10 \
    libsensor_s5kgw1sp03 \
    libsensor_ov64b40 \
    libsensor_gc6153 \
    libsensor_ov8856_xl_front \
    libsensor_ov02b1b \
    libsensor_ov02b10 \
    libsensor_ov8856_front_ts \
    libsensor_ov8856_back_ts \
    libsensor_s5k3p9sx04_ts \
    libsensor_ipg \
    libsensor_ov08a10_back_sunny \
    libsensor_s5khm2sp03 \
    libsensor_gc08a3_x6511 \
    libsensor_gc5035_x6511 \
	libsensor_virtual_sensor

ifeq ($(strip $(TARGET_BOARD_SENSOR_SS4C)),true)
PRODUCT_PACKAGES += libsensor_s5k3p9sp04 \
    libsensor_s5kgm1st_xl \
    libsensor_s5kgm2sp_dd
endif

ifeq ($(strip $(TARGET_BOARD_SENSOR_OV4C)),true)
PRODUCT_PACKAGES += libsensor_ov16885
endif

ifeq ($(strip $(TARGET_BOARD_SENSOR_SS4C_S5KJN1)),true)
PRODUCT_PACKAGES += libsensor_s5kjn1 libremosaic_wrapper \
	libsprd_fcell_ss libremosaiclib
endif

