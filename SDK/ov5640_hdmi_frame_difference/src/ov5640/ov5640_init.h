//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ov5640_init.h
// Last modified Date:  2019/07/01 15:59:46
// Last Version:        V1.0
// Descriptions:        ov5640配置
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/07/01 15:59:52
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//


#include "xil_types.h"
#include"sleep.h"

#ifndef OV5640_INIT_H_
#define OV5640_INIT_H_


u8 ov5640_init( u16 cmos_h_pixel, u16 cmos_v_pixel, u16 total_h_pixel, u16 total_v_pixel );


#endif /* OV5640_INIT_H_ */
