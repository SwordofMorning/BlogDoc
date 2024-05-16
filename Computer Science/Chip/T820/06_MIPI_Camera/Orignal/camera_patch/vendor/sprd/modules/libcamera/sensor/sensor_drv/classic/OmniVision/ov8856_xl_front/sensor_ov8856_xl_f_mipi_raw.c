/*
 * SPDX-FileCopyrightText: 2021-2022 Unisoc (Shanghai) Technologies Co., Ltd
 * SPDX-License-Identifier: LicenseRef-Unisoc-General-1.0
 *
 * Copyright 2021-2022 Unisoc (Shanghai) Technologies Co., Ltd.
 * Licensed under the Unisoc General Software License, version 1.0 (the License);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * https://www.unisoc.com/en_us/license/UNISOC_GENERAL_LICENSE_V1.0-EN_US
 * Software distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OF ANY KIND, either express or implied.
 * See the Unisoc General Software License, version 1.0 for more details.
 */
/*History
*Date                  Modification                                 Reason
*
*/

//#define LOG_TAG "ov8856_xl_f"
//#define OV8856_XL_MIPI_4LANE
#if defined(OV8856_XL_MIPI_4LANE)
#include "sensor_ov8856_xl_f_mipi_raw_4lane.h"
#else
#include "sensor_ov8856_xl_f_mipi_raw_2lane.h"
#endif

/*==============================================================================
 * Description:
 * write register value to sensor
 * please modify this function acording your spec
 *============================================================================*/

static void ov8856_drv_write_reg2sensor(cmr_handle handle,
                                        struct sensor_i2c_reg_tab *reg_info) {
    SENSOR_IC_CHECK_PTR_VOID(reg_info);
    SENSOR_IC_CHECK_HANDLE_VOID(handle);

    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    cmr_int i = 0;

    for (i = 0; i < reg_info->size; i++) {

        hw_sensor_write_reg(sns_drv_cxt->hw_handle,
                            reg_info->settings[i].reg_addr,
                            reg_info->settings[i].reg_value);
    }
}

/*==============================================================================
 * Description:
 * write gain to sensor registers buffer
 * please modify this function acording your spec
 *============================================================================*/
static void ov8856_drv_write_gain(cmr_handle handle,
                                  struct sensor_aec_i2c_tag *aec_info,
                                  cmr_u32 gain) {
    float gain_a = gain;
    float gain_d = 0x400; // spec p70, X1 = 15bit
    SENSOR_IC_CHECK_PTR_VOID(aec_info);
    SENSOR_IC_CHECK_HANDLE_VOID(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    if (SENSOR_MAX_GAIN < (cmr_u16)gain_a) {
        gain_a = SENSOR_MAX_GAIN;

        gain_d = (float)1.0f * gain * 0x400 / gain_a;
        if ((cmr_u16)gain_d > (0x4 * 0x400 - 1))
            gain_d = 0x4 * 0x400 - 1;
    }

    SENSOR_LOGD("(cmr_u16)gain_a = %f ,(cmr_u16)gain_d = %f", gain_a, gain_d);
    if (aec_info->again->size) {
        /*TODO*/
        aec_info->again->settings[2].reg_value = ((cmr_u16)gain_a >> 8) & 0x1f;
        aec_info->again->settings[3].reg_value = (cmr_u16)gain_a & 0xff;
        /*END*/
    }

    if (aec_info->dgain->size) {
        /*TODO*/
        aec_info->dgain->settings[0].reg_value = ((uint16_t)gain_d >> 8) & 0x0f;
        aec_info->dgain->settings[1].reg_value = (cmr_u16)gain_d & 0xff;
        aec_info->dgain->settings[2].reg_value = ((uint16_t)gain_d >> 8) & 0x0f;
        aec_info->dgain->settings[3].reg_value = (cmr_u16)gain_d & 0xff;
        aec_info->dgain->settings[4].reg_value = ((uint16_t)gain_d >> 8) & 0x0f;
        aec_info->dgain->settings[5].reg_value = (cmr_u16)gain_d & 0xff;
        aec_info->dgain->settings[6].reg_value = ((uint16_t)gain_d >> 8) & 0x0f;
        aec_info->dgain->settings[7].reg_value = (cmr_u16)gain_d & 0xff;
        /*END*/
    }
}

/*==============================================================================
 * Description:
 * write frame length to sensor registers buffer
 * please modify this function acording your spec
 *============================================================================*/
static void ov8856_drv_write_frame_length(cmr_handle handle,
                                          struct sensor_aec_i2c_tag *aec_info,
                                          cmr_u32 frame_len) {
    SENSOR_IC_CHECK_PTR_VOID(aec_info);
    SENSOR_IC_CHECK_HANDLE_VOID(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    if (aec_info->frame_length->size) {
        /*TODO*/

        aec_info->frame_length->settings[0].reg_value = (frame_len >> 8) & 0xff;
        aec_info->frame_length->settings[1].reg_value = frame_len & 0xff;
        /*END*/
    }
}

/*==============================================================================
 * Description:
 * write shutter to sensor registers buffer
 * please pay attention to the frame length
 * please modify this function acording your spec
 *============================================================================*/
static void ov8856_drv_write_shutter(cmr_handle handle,
                                     struct sensor_aec_i2c_tag *aec_info,
                                     cmr_u32 shutter) {
    SENSOR_IC_CHECK_PTR_VOID(aec_info);
    SENSOR_IC_CHECK_HANDLE_VOID(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    if (aec_info->shutter->size) {
        /*TODO*/
        aec_info->shutter->settings[0].reg_value = (shutter << 0x04) & 0xff;
        aec_info->shutter->settings[1].reg_value = (shutter >> 0x04) & 0xff;
        aec_info->shutter->settings[2].reg_value = (shutter >> 0x0c) & 0x0f;

        /*END*/
    }
}

/*==============================================================================
 * Description:
 * write exposure to sensor registers and get current shutter
 * please pay attention to the frame length
 * please don't change this function if it's necessary
 *============================================================================*/
static void ov8856_drv_calc_exposure(cmr_handle handle, cmr_u32 shutter,
                                     cmr_u32 dummy_line, cmr_u16 mode,
                                     struct sensor_aec_i2c_tag *aec_info) {
    cmr_u32 dest_fr_len = 0;
    cmr_u32 cur_fr_len = 0;
    cmr_u32 fr_len = 0;
    float fps = 0.0;
    cmr_u16 frame_interval = 0x00;

    SENSOR_IC_CHECK_PTR_VOID(aec_info);
    SENSOR_IC_CHECK_HANDLE_VOID(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    sns_drv_cxt->frame_length_def = sns_drv_cxt->trim_tab_info[mode].frame_line;
    sns_drv_cxt->line_time_def = sns_drv_cxt->trim_tab_info[mode].line_time;
    cur_fr_len = sns_drv_cxt->sensor_ev_info.preview_framelength;
    fr_len = sns_drv_cxt->frame_length_def;

    dummy_line = dummy_line > FRAME_OFFSET ? dummy_line : FRAME_OFFSET;
    dest_fr_len =
        ((shutter + dummy_line) > fr_len) ? (shutter + dummy_line) : fr_len;
    sns_drv_cxt->frame_length = dest_fr_len;

    if (shutter < SENSOR_MIN_SHUTTER)
        shutter = SENSOR_MIN_SHUTTER;

    if (cur_fr_len > shutter) {
        fps = 1000000000.0 /
              (cur_fr_len * sns_drv_cxt->trim_tab_info[mode].line_time);
    } else {
        fps = 1000000000.0 / ((shutter + dummy_line) *
                              sns_drv_cxt->trim_tab_info[mode].line_time);
    }

    frame_interval = (uint16_t)(
        ((shutter + dummy_line) * sns_drv_cxt->line_time_def) / 1000000);
    SENSOR_LOGD("mode = %d, exposure_line = %d, dummy_line= %d, "
                "frame_interval= %d ms, fps = %f",
                mode, shutter, dummy_line, frame_interval, fps);

    if (dest_fr_len != cur_fr_len) {
        sns_drv_cxt->sensor_ev_info.preview_framelength = dest_fr_len;
        ov8856_drv_write_frame_length(handle, aec_info, dest_fr_len);
    }
    sns_drv_cxt->sensor_ev_info.preview_shutter = shutter;
    ov8856_drv_write_shutter(handle, aec_info, shutter);
}

static void ov8856_drv_calc_gain(cmr_handle handle, cmr_uint isp_gain,
                                 struct sensor_aec_i2c_tag *aec_info) {
    SENSOR_IC_CHECK_HANDLE_VOID(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    cmr_u32 sensor_gain = 0;

    sensor_gain = isp_gain < SENSOR_BASE_GAIN ? SENSOR_BASE_GAIN : isp_gain;
    sensor_gain = sensor_gain * SENSOR_BASE_GAIN / ISP_BASE_GAIN;

    SENSOR_LOGV("isp_gain = 0x%x,sensor_gain=0x%x", (unsigned int)isp_gain,
                sensor_gain);

    sns_drv_cxt->sensor_ev_info.preview_gain = sensor_gain;
    ov8856_drv_write_gain(handle, aec_info, sensor_gain);
}

/*==============================================================================
 * Description:
 * sensor power on
 * please modify this function acording your spec
 *============================================================================*/
static cmr_int ov8856_drv_power_on(cmr_handle handle, cmr_uint power_on) {
    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    struct module_cfg_info *module_info = sns_drv_cxt->module_info;

    SENSOR_AVDD_VAL_E dvdd_val = module_info->dvdd_val;
    SENSOR_AVDD_VAL_E avdd_val = module_info->avdd_val;
    SENSOR_AVDD_VAL_E iovdd_val = module_info->iovdd_val;
    BOOLEAN power_down = g_ov8856_xl_f_mipi_raw_info.power_down_level;
    BOOLEAN reset_level = g_ov8856_xl_f_mipi_raw_info.reset_pulse_level;

    if (SENSOR_TRUE == power_on) {
        hw_sensor_power_down(sns_drv_cxt->hw_handle, power_down);
        hw_sensor_set_reset_level(sns_drv_cxt->hw_handle, reset_level);
        hw_sensor_set_mclk(sns_drv_cxt->hw_handle, SENSOR_DISABLE_MCLK);
        hw_sensor_set_avdd_val(sns_drv_cxt->hw_handle, SENSOR_AVDD_CLOSED);
        hw_sensor_set_dvdd_val(sns_drv_cxt->hw_handle, SENSOR_AVDD_CLOSED);
        hw_sensor_set_iovdd_val(sns_drv_cxt->hw_handle, SENSOR_AVDD_CLOSED);

        usleep(1 * 1000);
        hw_sensor_set_iovdd_val(sns_drv_cxt->hw_handle, iovdd_val);
        hw_sensor_set_avdd_val(sns_drv_cxt->hw_handle, avdd_val);
        hw_sensor_set_dvdd_val(sns_drv_cxt->hw_handle, dvdd_val);

        usleep(1 * 1000);
        hw_sensor_power_down(sns_drv_cxt->hw_handle, !power_down);
        hw_sensor_set_reset_level(sns_drv_cxt->hw_handle, !reset_level);
        usleep(5 * 1000);
        hw_sensor_set_mclk(sns_drv_cxt->hw_handle, EX_MCLK);
        usleep(500);
    } else {
        hw_sensor_set_mclk(sns_drv_cxt->hw_handle, SENSOR_DISABLE_MCLK);
        usleep(500);
        hw_sensor_set_reset_level(sns_drv_cxt->hw_handle, reset_level);
        hw_sensor_power_down(sns_drv_cxt->hw_handle, power_down);
        usleep(200);
        hw_sensor_set_avdd_val(sns_drv_cxt->hw_handle, SENSOR_AVDD_CLOSED);
        hw_sensor_set_dvdd_val(sns_drv_cxt->hw_handle, SENSOR_AVDD_CLOSED);
        hw_sensor_set_iovdd_val(sns_drv_cxt->hw_handle, SENSOR_AVDD_CLOSED);
    }

    SENSOR_LOGI("(1:on, 0:off): %lu", power_on);
    return SENSOR_SUCCESS;
}

/*==============================================================================
 * Description:
 * calculate fps for every sensor mode according to frame_line and line_time
 * please modify this function acording your spec
 *============================================================================*/
static cmr_int ov8856_drv_init_fps_info(cmr_handle handle) {
    cmr_int rtn = SENSOR_SUCCESS;
    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    struct sensor_fps_info *fps_info = sns_drv_cxt->fps_info;
    struct sensor_trim_tag *trim_info = sns_drv_cxt->trim_tab_info;
    struct sensor_static_info *static_info = sns_drv_cxt->static_info;

    SENSOR_LOGI("E");
    if (!fps_info->is_init) {
        cmr_u32 i, modn, tempfps = 0;
        SENSOR_LOGI("start init");
        for (i = 0; i < SENSOR_MODE_MAX; i++) {
            // max fps should be multiple of 30,it calulated from line_time and
            // frame_line
            tempfps = trim_info[i].line_time * trim_info[i].frame_line;
            if (0 != tempfps) {
                tempfps = 1000000000 / tempfps;
                modn = tempfps / 30;
                if (tempfps > modn * 30)
                    modn++;
                fps_info->sensor_mode_fps[i].max_fps = modn * 30;
                if (fps_info->sensor_mode_fps[i].max_fps > 30) {
                    fps_info->sensor_mode_fps[i].is_high_fps = 1;
                    fps_info->sensor_mode_fps[i].high_fps_skip_num =
                        fps_info->sensor_mode_fps[i].max_fps / 30;
                }
                if (fps_info->sensor_mode_fps[i].max_fps >
                    static_info->max_fps) {
                    static_info->max_fps = fps_info->sensor_mode_fps[i].max_fps;
                }
            }
            SENSOR_LOGI("mode %d,tempfps %d,frame_len %d,line_time: %d ", i,
                        tempfps, trim_info[i].frame_line,
                        trim_info[i].line_time);
            SENSOR_LOGI("mode %d,max_fps: %d ", i,
                        fps_info->sensor_mode_fps[i].max_fps);
            SENSOR_LOGI("is_high_fps: %d,highfps_skip_num %d",
                        fps_info->sensor_mode_fps[i].is_high_fps,
                        fps_info->sensor_mode_fps[i].high_fps_skip_num);
        }
        fps_info->is_init = 1;
    }
    SENSOR_LOGI("X");
    return rtn;
}

static cmr_int ov8856_drv_get_static_info(cmr_handle handle, cmr_u32 *param) {
    cmr_int rtn = SENSOR_SUCCESS;
    struct sensor_ex_info *ex_info = (struct sensor_ex_info *)param;
    cmr_u32 up = 0;
    cmr_u32 down = 0;

    SENSOR_IC_CHECK_HANDLE(handle);
    SENSOR_IC_CHECK_PTR(ex_info);
    SENSOR_IC_CHECK_PTR(param);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    struct sensor_fps_info *fps_info = sns_drv_cxt->fps_info;
    struct sensor_static_info *static_info = sns_drv_cxt->static_info;
    struct module_cfg_info *module_info = sns_drv_cxt->module_info;

    // make sure we have get max fps of all settings.
    if (!fps_info->is_init) {
        ov8856_drv_init_fps_info(handle);
    }
    ex_info->f_num = static_info->f_num;
    ex_info->focal_length = static_info->focal_length;
    ex_info->max_fps = static_info->max_fps;
    ex_info->max_adgain = static_info->max_adgain;
    ex_info->ois_supported = static_info->ois_supported;
    ex_info->pdaf_supported = static_info->pdaf_supported;
    ex_info->exp_valid_frame_num = static_info->exp_valid_frame_num;
    ex_info->clamp_level = static_info->clamp_level;
    ex_info->adgain_valid_frame_num = static_info->adgain_valid_frame_num;
    ex_info->preview_skip_num = module_info->preview_skip_num;
    ex_info->capture_skip_num = module_info->capture_skip_num;
    ex_info->name = (cmr_s8 *)g_ov8856_xl_f_mipi_raw_info.name;
    ex_info->sensor_version_info =
        (cmr_s8 *)g_ov8856_xl_f_mipi_raw_info.sensor_version_info;
    memcpy(&ex_info->fov_info, &static_info->fov_info,
           sizeof(static_info->fov_info));

    ex_info->pos_dis.up2hori = up;
    ex_info->pos_dis.hori2down = down;
    sensor_ic_print_static_info((cmr_s8 *)SENSOR_NAME, ex_info);

    return rtn;
}

static cmr_int ov8856_drv_get_fps_info(cmr_handle handle, cmr_u32 *param) {
    cmr_int rtn = SENSOR_SUCCESS;
    SENSOR_MODE_FPS_T *fps_info = (SENSOR_MODE_FPS_T *)param;
    SENSOR_IC_CHECK_HANDLE(handle);
    SENSOR_IC_CHECK_PTR(fps_info);
    SENSOR_IC_CHECK_PTR(param);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    struct sensor_fps_info *fps_data = sns_drv_cxt->fps_info;

    // make sure have inited fps of every sensor mode.
    if (!fps_data->is_init) {
        ov8856_drv_init_fps_info(handle);
    }
    cmr_u32 sensor_mode = fps_info->mode;
    fps_info->max_fps = fps_data->sensor_mode_fps[sensor_mode].max_fps;
    fps_info->min_fps = fps_data->sensor_mode_fps[sensor_mode].min_fps;
    fps_info->is_high_fps = fps_data->sensor_mode_fps[sensor_mode].is_high_fps;
    fps_info->high_fps_skip_num =
        fps_data->sensor_mode_fps[sensor_mode].high_fps_skip_num;
    SENSOR_LOGV("mode %d, max_fps: %d", fps_info->mode, fps_info->max_fps);
    SENSOR_LOGV("min_fps: %d", fps_info->min_fps);
    SENSOR_LOGV("is_high_fps: %d", fps_info->is_high_fps);
    SENSOR_LOGV("high_fps_skip_num: %d", fps_info->high_fps_skip_num);

    return rtn;
}

static cmr_u8 ov8856_otp_module_vendor_id = 0;
static cmr_int ov8856_drv_set_raw_info(cmr_handle handle, cmr_u8 *param) {
    cmr_int rtn = SENSOR_SUCCESS;
    SENSOR_LOGV("vendor_id %x", *param);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    struct sensor_drv_context *sensor_cxt =
        (struct sensor_drv_context *)sns_drv_cxt->caller_handle;
    otp_drv_cxt_t *otp_cxt = (otp_drv_cxt_t *)sensor_cxt->otp_drv_handle;

    if (otp_cxt) {
        cmr_u8 *otp = otp_cxt->otp_raw_data.buffer;
        SENSOR_LOGV("otp_raw_data version 0x: %02x %02x %02x %02x %02x %02x",
                    otp[0], otp[1], otp[2], otp[3], otp[4], otp[5]);
        SENSOR_LOGV("otp_raw_data map 0x: %02x %02x %02x %02x", otp[6], otp[7],
                    otp[8], otp[9]);
        SENSOR_LOGV("otp_raw_data module_id 0x: %02x %02x %02x %02x %02x %02x",
                    otp[10], otp[11], otp[12], otp[13], otp[14], otp[15]);
        SENSOR_LOGV("otp_raw_data date: 0x %02x-%02x-%02x, %d-%d-%d", otp[16],
                    otp[17], otp[18], otp[16], otp[17], otp[18]);
        ov8856_otp_module_vendor_id = otp[10];
        SENSOR_LOGV("ov8856_otp_module_vendor_id = 0x%x",
                    ov8856_otp_module_vendor_id);
    } else {
        SENSOR_LOGI("no otp_cxt");
    }

    return rtn;
}

/*==============================================================================
 * Description:
 * cfg otp setting
 * please modify this function acording your spec
 *============================================================================*/
static cmr_int ov8856_drv_access_val(cmr_handle handle, cmr_uint param) {
    cmr_int ret = SENSOR_FAIL;
    SENSOR_VAL_T *param_ptr = (SENSOR_VAL_T *)param;
    char value[255];

    SENSOR_IC_CHECK_HANDLE(handle);
    SENSOR_IC_CHECK_PTR(param_ptr);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    SENSOR_LOGV("sensor ov8856: param_ptr->type=%x", param_ptr->type);

    switch (param_ptr->type) {
    case SENSOR_VAL_TYPE_GET_STATIC_INFO:
        ret = ov8856_drv_get_static_info(handle, param_ptr->pval);
        break;
    case SENSOR_VAL_TYPE_GET_FPS_INFO:
        ret = ov8856_drv_get_fps_info(handle, param_ptr->pval);
        break;
    case SENSOR_VAL_TYPE_GET_PDAF_INFO:
        // ret = ov8856_drv_get_pdaf_info(handle, param_ptr->pval);
        break;
    case SENSOR_VAL_TYPE_SET_RAW_INFOR:
        ov8856_drv_set_raw_info(handle, param_ptr->pval);
        break;
    #if defined(OV8856_NO_VCM_SENSOR_OTP)
    case SENSOR_VAL_TYPE_READ_OTP:
        property_get("persist.vendor.bypass.sensor.otp", value, "0");
        if (atoi(value) == 0) {
            if (ov8856_otp_module_vendor_id == 0 && sns_drv_cxt->sensor_id == 1)
                ov8856_read_otp(handle, param_ptr);
        }
        break;
    #endif
    default:
        break;
    }
    ret = SENSOR_SUCCESS;

    return ret;
}

/*==============================================================================
 * Description:
 * identify sensor id
 * please modify this function acording your spec
 *============================================================================*/
static cmr_int ov8856_drv_identify(cmr_handle handle, cmr_uint param) {
    cmr_u16 pid_value = 0x00;
    cmr_u16 ver_value = 0x00;
    cmr_int ret_value = SENSOR_FAIL;

    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
#ifdef OV8856_XL_MIPI_4LANE
    SENSOR_LOGI("4lane mipi raw identify");
#else
    SENSOR_LOGI("front 2lane mipi raw identify");
#endif

    pid_value = hw_sensor_read_reg(sns_drv_cxt->hw_handle, ov8856_PID_ADDR);

    if (ov8856_PID_VALUE == pid_value) {
        ver_value = hw_sensor_read_reg(sns_drv_cxt->hw_handle, ov8856_VER_ADDR);
        SENSOR_LOGI("Identify: pid_value = %x, ver_value = %x", pid_value,
                    ver_value);
        if (ov8856_VER_VALUE == ver_value) {
            // Sensor_InitRawTuneInfo(sns_drv_cxt);
            SENSOR_LOGI("front this is ov8856 sensor");
            ret_value = SENSOR_SUCCESS;
        } else {
            SENSOR_LOGI("sensor identify fail, pid_value = %x, ver_value = %x",
                        pid_value, ver_value);
        }
    } else {
        SENSOR_LOGI("sensor identify fail, pid_value = %x, ver_value = %x",
                    pid_value, ver_value);
    }

    return ret_value;
}

/*==============================================================================
 * Description:
 * before snapshot
 * you can change this function if it's necessary
 *============================================================================*/
static cmr_int ov8856_drv_before_snapshot(cmr_handle handle, cmr_uint param) {
    cmr_u32 cap_shutter = 0;
    cmr_u32 prv_shutter = 0;
    cmr_u32 prv_gain = 0;
    cmr_u32 cap_gain = 0;
    cmr_u32 capture_mode = param & 0xffff;
    cmr_u32 preview_mode = (param >> 0x10) & 0xffff;

    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    SENSOR_LOGI("preview_mode=%d,capture_mode = %d", preview_mode,
                capture_mode);
    SENSOR_LOGI("preview_shutter = 0x%x, preview_gain = 0x%x",
                sns_drv_cxt->sensor_ev_info.preview_shutter,
                (unsigned int)sns_drv_cxt->sensor_ev_info.preview_gain);

    cmr_u32 prv_linetime = sns_drv_cxt->trim_tab_info[preview_mode].line_time;
    cmr_u32 cap_linetime = sns_drv_cxt->trim_tab_info[capture_mode].line_time;

    if (sns_drv_cxt->ops_cb.set_mode)
        sns_drv_cxt->ops_cb.set_mode(sns_drv_cxt->caller_handle, capture_mode);
    if (sns_drv_cxt->ops_cb.set_mode_wait_done)
        sns_drv_cxt->ops_cb.set_mode_wait_done(sns_drv_cxt->caller_handle);

    if (preview_mode == capture_mode) {
        cap_shutter = sns_drv_cxt->sensor_ev_info.preview_shutter;
        cap_gain = sns_drv_cxt->sensor_ev_info.preview_gain;
        goto snapshot_info;
    }

    prv_shutter = sns_drv_cxt->sensor_ev_info.preview_shutter;
    prv_gain = sns_drv_cxt->sensor_ev_info.preview_gain;

    cap_shutter = prv_shutter * prv_linetime / cap_linetime * BINNING_FACTOR;
    cap_gain = prv_gain;

    SENSOR_LOGI("capture_shutter = 0x%x, capture_gain = 0x%x", cap_shutter,
                cap_gain);

    ov8856_drv_calc_exposure(handle, cap_shutter, 0, capture_mode,
                             &ov8856_aec_info);
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.frame_length);
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.shutter);

    sns_drv_cxt->sensor_ev_info.preview_gain = cap_gain;
    ov8856_drv_write_gain(handle, &ov8856_aec_info, cap_gain);
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.again);
#if !defined(OV8856_NO_VCM_SENSOR_OTP)
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.dgain);
#endif

snapshot_info:
    if (sns_drv_cxt->ops_cb.set_exif_info) {
        // sns_drv_cxt->ops_cb.set_exif_info(sns_drv_cxt->caller_handle,
        // SENSOR_EXIF_CTRL_EXPOSURETIME, cap_shutter);
    } else {
        sns_drv_cxt->exif_info.exposure_line = cap_shutter;
    }

    return SENSOR_SUCCESS;
}

/*==============================================================================
 * Description:
 * get the shutter from isp and write senosr shutter register
 * please don't change this function unless it's necessary
 *============================================================================*/
static cmr_int ov8856_drv_write_exposure(cmr_handle handle, cmr_uint param) {
    cmr_int ret_value = SENSOR_SUCCESS;
    cmr_u16 exposure_line = 0x00;
    cmr_u16 dummy_line = 0x00;
    cmr_u16 size_index = 0x00;

    struct sensor_ex_exposure *ex = (struct sensor_ex_exposure *)param;
    SENSOR_IC_CHECK_HANDLE(handle);
    SENSOR_IC_CHECK_HANDLE(ex);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    exposure_line = ex->exposure;
    dummy_line = ex->dummy;
    size_index = ex->size_index;

    ov8856_drv_calc_exposure(handle, exposure_line, dummy_line, size_index,
                             &ov8856_aec_info);
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.frame_length);
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.shutter);

    return ret_value;
}

/*==============================================================================
 * Description:
 * write gain value to sensor
 * you can change this function if it's necessary
 *============================================================================*/
static cmr_int ov8856_drv_write_gain_value(cmr_handle handle, cmr_uint param) {
    cmr_int ret_value = SENSOR_SUCCESS;

    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    ov8856_drv_calc_gain(handle, param, &ov8856_aec_info);
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.again);
#if !defined(OV8856_NO_VCM_SENSOR_OTP)
    ov8856_drv_write_reg2sensor(handle, ov8856_aec_info.dgain);
#endif
    return ret_value;
}

/*==============================================================================
 * Description:
 * read ae control info
 * please don't change this function unless it's necessary
 *============================================================================*/
static cmr_int ov8856_drv_read_aec_info(cmr_handle handle, cmr_uint param) {
    cmr_int ret_value = SENSOR_SUCCESS;
    struct sensor_aec_reg_info *info = (struct sensor_aec_reg_info *)param;
    cmr_u16 exposure_line = 0x00;
    cmr_u16 dummy_line = 0x00;
    cmr_u16 mode = 0x00;
    SENSOR_IC_CHECK_HANDLE(handle);
    SENSOR_IC_CHECK_PTR(info);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    info->aec_i2c_info_out = &ov8856_aec_info;
    exposure_line = info->exp.exposure;
    dummy_line = info->exp.dummy;
    mode = info->exp.size_index;

    ov8856_drv_calc_exposure(handle, exposure_line, dummy_line, mode,
                             &ov8856_aec_info);
    ov8856_drv_calc_gain(handle, info->gain, &ov8856_aec_info);

    return ret_value;
}

static cmr_int ov8856_drv_set_master_FrameSync(cmr_handle handle,
                                               cmr_uint param) {
    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    SENSOR_LOGI("E");

    /*TODO*/

    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3028, 0x20);

    /*END*/

    return SENSOR_SUCCESS;
}
unsigned long ov8856s_SetSlave_FrameSync(cmr_handle handle,
                                         unsigned long param) {
    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3000,
                        0x00); // bit 5 0 input 1 output 0x3003?
    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3823, 0x58);
    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3824, 0x00);
    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3825, 0x20);
    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3826, 0x00);
    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3827, 0x07);
    SENSOR_LOGI("X");

    return 0;
}

/*==============================================================================
 * Description:
 * mipi stream on
 * please modify this function acording your spec
 *============================================================================*/
static cmr_int ov8856_drv_stream_on(cmr_handle handle, cmr_uint param) {
    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;
    struct sensor_drv_context *sensor_cxt =
        (struct sensor_drv_context *)sns_drv_cxt->caller_handle;
    cmr_u32 mode = sensor_cxt->sensor_mode;

    char value1[PROPERTY_VALUE_MAX];
    property_get("persist.vendor.cam.colorbar", value1, "0");
    if (!strcmp(value1, "1")) {
        hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5e00, 0x80);
    }

    SENSOR_LOGI("E:ov8856_otp_module_vendor_id = 0x%x, sensor_mode %d",
                ov8856_otp_module_vendor_id, mode);
    if (ov8856_otp_module_vendor_id == 1) {
        /* ov8856 sharkl3 back_slave and front old camera module, 2 lane,
         * IMAGE_HV_MIRROR */
        if (mode == 3 /*ov8856_snapshot_setting*/) {
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3820, 0xc6);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3821, 0x00);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x502e, 0x00);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5001, 0x0e);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5004, 0x00);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x376b, 0x36);
        } else { /*ov8856_video_setting + ov8856_preview_setting*/
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3820, 0xd6);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3821, 0x21);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x502e, 0x00);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5001, 0x0e);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5004, 0x00);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x376b, 0x36);
        }
        if (sns_drv_cxt->sensor_id == 2)
            ov8856s_SetSlave_FrameSync(handle, param);
    } else {
        /* ov8856 sharkl5 front camera module, sharkl3 back_slave and front new
         * camera module, or SENSOR_OV8856_TELE, 2 lane, IMAGE_NORMAL_MIRROR */
        /* ov8856 sharkle and pike2 back single camera module, 4 lane,
         * IMAGE_H_MIRROR */
        if (mode == 3 /*ov8856_snapshot_setting*/) {
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3820, 0x80);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3821, 0x46);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x502e, 0x03);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5001, 0x0a);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5004, 0x04);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x376b, 0x30);
        } else { /*ov8856_video_setting + ov8856_preview_setting*/
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3820, 0x90);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x3821, 0x67);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x502e, 0x03);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5001, 0x0a);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x5004, 0x04);
            hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x376b, 0x30);
        }
    }

#if 0 // defined(CONFIG_DUAL_MODULE)
//#ifndef SENSOR_OV8856_TELE
    if (sns_drv_cxt->sensor_id == 2)
        ov8856s_SetSlave_FrameSync(handle, param);
//#endif
#endif

#if 0 // defined(CONFIG_DUAL_MODULE)
	ov8856_drv_set_master_FrameSync(handle, param);
#endif
    /*TODO*/

    hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x0100, 0x01);

    /*END*/

    /*delay*/
    usleep(1 * 1000);

    SENSOR_LOGI("X");
    return SENSOR_SUCCESS;
}

/*==============================================================================
 * Description:
 * mipi stream off
 * please modify this function acording your spec
 *============================================================================*/
static cmr_int ov8856_drv_stream_off(cmr_handle handle, cmr_uint param) {
    SENSOR_LOGI("E");
    unsigned char value = 0;
    cmr_u16 sleep_time = 0;
    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    value = hw_sensor_read_reg(sns_drv_cxt->hw_handle, 0x0100);
    if (value != 0x00) {
        hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x0100, 0x00);
        sleep_time = (sns_drv_cxt->sensor_ev_info.preview_framelength *
                      sns_drv_cxt->line_time_def / 1000000) + 10;
        usleep(sleep_time * 1000);
        SENSOR_LOGI("stream_off delay_ms %d", sleep_time);
    } else {
        hw_sensor_write_reg(sns_drv_cxt->hw_handle, 0x0100, 0x00);
    }

    return SENSOR_SUCCESS;
}

static cmr_int
ov8856_drv_handle_create(struct sensor_ic_drv_init_para *init_param,
                         cmr_handle *sns_ic_drv_handle) {
    cmr_int ret = SENSOR_SUCCESS;
    struct sensor_ic_drv_cxt *sns_drv_cxt = NULL;
    void *pri_data = NULL;

    ret = sensor_ic_drv_create(init_param, sns_ic_drv_handle);
    sns_drv_cxt = *sns_ic_drv_handle;

    sns_drv_cxt->sensor_ev_info.preview_shutter =
        PREVIEW_FRAME_LENGTH - FRAME_OFFSET;
    sns_drv_cxt->sensor_ev_info.preview_gain = SENSOR_BASE_GAIN;
    sns_drv_cxt->sensor_ev_info.preview_framelength = PREVIEW_FRAME_LENGTH;

    sns_drv_cxt->frame_length_def = PREVIEW_FRAME_LENGTH;
    sns_drv_cxt->line_time_def = PREVIEW_LINE_TIME;

    ov8856_drv_write_frame_length(
        sns_drv_cxt, &ov8856_aec_info,
        sns_drv_cxt->sensor_ev_info.preview_framelength);
    ov8856_drv_write_gain(sns_drv_cxt, &ov8856_aec_info,
                          sns_drv_cxt->sensor_ev_info.preview_gain);
    ov8856_drv_write_shutter(sns_drv_cxt, &ov8856_aec_info,
                             sns_drv_cxt->sensor_ev_info.preview_shutter);

    sensor_ic_set_match_module_info(sns_drv_cxt,
                                    ARRAY_SIZE(s_ov8856_module_info_tab),
                                    s_ov8856_module_info_tab);
    sensor_ic_set_match_resolution_info(sns_drv_cxt,
                                        ARRAY_SIZE(s_ov8856_resolution_tab_raw),
                                        s_ov8856_resolution_tab_raw);
    sensor_ic_set_match_trim_info(sns_drv_cxt,
                                  ARRAY_SIZE(s_ov8856_resolution_trim_tab),
                                  s_ov8856_resolution_trim_tab);
    sensor_ic_set_match_static_info(
        sns_drv_cxt, ARRAY_SIZE(s_ov8856_static_info), s_ov8856_static_info);
    sensor_ic_set_match_fps_info(sns_drv_cxt,
                                 ARRAY_SIZE(s_ov8856_mode_fps_info),
                                 s_ov8856_mode_fps_info);

    /*init exif info,this will be deleted in the future*/
    ov8856_drv_init_fps_info(sns_drv_cxt);

    /*add private here*/
    return ret;
}

static cmr_int ov8856_drv_handle_delete(cmr_handle handle, void *param) {
    cmr_int ret = SENSOR_SUCCESS;

    SENSOR_IC_CHECK_HANDLE(handle);
    struct sensor_ic_drv_cxt *sns_drv_cxt = (struct sensor_ic_drv_cxt *)handle;

    ret = sensor_ic_drv_delete(handle, param);
    return ret;
}

static cmr_int ov8856_drv_get_private_data(cmr_handle handle, cmr_uint cmd,
                                           void **param) {
    cmr_int ret = SENSOR_SUCCESS;
    SENSOR_IC_CHECK_HANDLE(handle);
    SENSOR_IC_CHECK_PTR(param);

    ret = sensor_ic_get_private_data(handle, cmd, param);
    return ret;
}

void *sensor_ic_open_lib(void)
{
     return &g_ov8856_xl_f_mipi_raw_info;
}
/*==============================================================================
 * Description:
 * all ioctl functoins
 * you can add functions reference SENSOR_IOCTL_FUNC_TAB_T from sensor_drv_u.h
 *
 * add ioctl functions like this:
 * .power = ov8856_power_on,
 *============================================================================*/
static struct sensor_ic_ops s_ov8856_ops_tab = {
    .create_handle = ov8856_drv_handle_create,
    .delete_handle = ov8856_drv_handle_delete,
    .get_data = ov8856_drv_get_private_data,
    /*---------------------------------------*/
    .power = ov8856_drv_power_on,
    .identify = ov8856_drv_identify,
    .ex_write_exp = ov8856_drv_write_exposure,
    .write_gain_value = ov8856_drv_write_gain_value,

#if defined(CONFIG_DUAL_MODULE)
    .read_aec_info = ov8856_drv_read_aec_info,
#endif

    .ext_ops = {
            [SENSOR_IOCTL_BEFORE_SNAPSHOT].ops = ov8856_drv_before_snapshot,
            [SENSOR_IOCTL_STREAM_ON].ops = ov8856_drv_stream_on,
            [SENSOR_IOCTL_STREAM_OFF].ops = ov8856_drv_stream_off,
            /* expand interface,if you want to add your sub cmd ,
             *  you can add it in enum {@SENSOR_IOCTL_VAL_TYPE}
             */
            [SENSOR_IOCTL_ACCESS_VAL].ops = ov8856_drv_access_val,
    }};
