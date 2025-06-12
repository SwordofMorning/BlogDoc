#!/bin/sh


b_sensor0_set=0
b_sensor1_set=0
b_sensor2_set=0
b_sensor3_set=0

SNS_TYPE0=imx334;    # sensor type
SNS_TYPE1=imx334;    # sensor type
SNS_TYPE2=imx334;    # sensor type
SNS_TYPE3=imx334;    # sensor type

vc_performance=0

#DDR start:0x20000000, DSP(15M); kernel start:0x20F00000, OS(512M); MMZ start:0x40F00000
mem_total=2048
mem_start=0x20000000
dsp_mem_size=15
os_mem_size=512
mmz_start=0x40f00000
mmz_size=0x5f100000
reserved_mem_size=0

get_sensor_clk()
{
	case $1 in
		"imx334")	echo "37125000";;
		"imx347")	echo "37125000";;
		"imx485")	echo "37125000";;
		"imx415")	echo "37125000";;
		"imx385")	echo "37125000";;
		"imx305")	echo "74250000";;
		"imx686")	echo "24000000";;
		"imx586")	echo "24000000";;
		"os08a10")	echo "24000000";;
		"os04a10")	echo "24000000";;
		"os08a20")	echo "24000000";;
		"sc450ai")	echo "24000000";;
		"gmax3809")	echo "24000000";;
		*)	echo "37125000";;
	esac
}

load_usage()
{
	echo "Usage:  ./load8x9.sh [ -r|-i] [-sensor0~3]"
	echo "options:"
	echo "    -h                       help information"
	echo "    -i                       insmod all modules"
	echo "    -r                       remove all modules"
	echo "    -p                       vc performance"
	echo "    -sensor0~3 sensor_name   config sensor type [default: imx334]"
	echo "    -mem_total mem_size      config total mem size [unit: M, default: 2048]"
	echo "    -osmem os_mem_size       config os mem size [unit: M, default: 512]"

	echo -e "Available sensors: imx334 imx347 os08a10 os04a10 sc450ai imx415 imx305 imx385 imx485 os08a20 ..."
	echo -e "for example: ./load8x9.sh -i -p -sensor0 imx334 -sensor1 imx334 -sensor2 imx334 -sensor3 imx334 -mem_total 2048 -osmem 512\n"
}

remove_ko()
{
	rmmod vs_regtools
	rmmod vs_mipi_tx
	rmmod vs_hdmi
	rmmod vs_tdc
	rmmod vs_vdec
	rmmod vs_venc
	rmmod vs_fb
	rmmod vs_vo
	rmmod vs_vpp
	rmmod vs_gpe
	rmmod vipcore
	rmmod galcore
	rmmod vs_gdc
	rmmod vs_vii
	rmmod vs_ispbe
	rmmod vs_ispfe
	rmmod vs_ysum
	rmmod vs_aout
	rmmod vs_ain
	rmmod vs_aenc
	rmmod vs_adec
	rmmod vs_acodec
	rmmod vs_aio
	rmmod vs_dma
	rmmod vs_mipi_rx
	rmmod vs_ive
	rmmod vs_dsp
	rmmod vs_rgn
	#rmmod vs_diag
	rmmod vs_ipcm
	rmmod vs_sys
	rmmod vs_init
	rmmod vs_base
	rmmod vs_osal
}

insert_ko()
{
	insmod /lib/modules/vs_osal.ko
	insmod /lib/modules/vs_base.ko mmz=null,$mmz_start,$mmz_size:mbuf,0xdc40000,0xc0000
	insmod /lib/modules/vs_sys.ko vc=$vc_performance
	insmod /lib/modules/vs_ipcm.ko
	insmod /lib/modules/vs_init.ko
	#insmod /lib/modules/vs_diag.ko
	insmod /lib/modules/vs_rgn.ko
	insmod /lib/modules/vs_dsp.ko
	insmod /lib/modules/vs_ive.ko
	insmod /lib/modules/vs_mipi_rx.ko
	insmod /lib/modules/vs_dma.ko
	insmod /lib/modules/vs_aio.ko
	insmod /lib/modules/vs_acodec.ko
	insmod /lib/modules/vs_adec.ko
	insmod /lib/modules/vs_aenc.ko
	insmod /lib/modules/vs_ain.ko
	insmod /lib/modules/vs_aout.ko
	insmod /lib/modules/vs_ysum.ko
	insmod /lib/modules/vs_ispfe.ko
	insmod /lib/modules/vs_ispbe.ko
	if [ $b_sensor0_set -eq 1 ] ; then
		echo "=======sensor0=$SNS_TYPE0============="
	fi
	if [ $b_sensor1_set -eq 1 ] ; then
		echo "=======sensor1=$SNS_TYPE1============="
	fi
	if [ $b_sensor2_set -eq 1 ] ; then
		echo "=======sensor2=$SNS_TYPE2============="
	fi
	if [ $b_sensor3_set -eq 1 ] ; then
		echo "=======sensor3=$SNS_TYPE3============="
	fi
	SNS_CLK=`get_sensor_clk $SNS_TYPE0`
	SNS_CLK=$SNS_CLK","`get_sensor_clk $SNS_TYPE1`
	SNS_CLK=$SNS_CLK","`get_sensor_clk $SNS_TYPE2`
	SNS_CLK=$SNS_CLK","`get_sensor_clk $SNS_TYPE3`
	insmod /lib/modules/vs_vii.ko sensor_clk=$SNS_CLK
	insmod /lib/modules/vs_gdc.ko
	insmod /lib/modules/galcore.ko
	insmod /lib/modules/vipcore.ko
	insmod /lib/modules/vs_gpe.ko
	insmod /lib/modules/vs_vpp.ko
	insmod /lib/modules/vs_vo.ko
	insmod /lib/modules/vs_fb.ko
	insmod /lib/modules/vs_venc.ko
	insmod /lib/modules/vs_vdec.ko
	insmod /lib/modules/vs_tdc.ko
	insmod /lib/modules/vs_hdmi.ko
	insmod /lib/modules/vs_mipi_tx.ko
	insmod /lib/modules/vs_regtools.ko
}

calc_mmz()
{
	if [ $mem_total -gt 3584 ]; then
		mem_total=3584;
	fi
	eval $(echo "$mem_start $os_mem_size $dsp_mem_size $reserved_mem_size $mem_total" |
	awk 'BEGIN { start = 0; size = 0;}
	{
		start = $1/1024/1024 + $2 + $3;
		size = $5 - $2 - $3 - $4;
	}
	END
	{
		printf("mmz_start=0x%x00000\n", start);
		printf("mmz_size=0x%x00000\n", size);
	}')
	echo "mmz_start: $mmz_start, mmz_size: $mmz_size"
}

######################parse arg###################################
b_arg_sensor0=0
b_arg_sensor1=0
b_arg_sensor2=0
b_arg_sensor3=0
b_arg_insmod=0
b_arg_remove=0
b_arg_total_mem=0
b_arg_os_mem=0
b_arg_perfomance=0

if [ $# -lt 1 ]; then
	load_usage;
	exit 0;
fi

for arg in $@
do
	if [ $b_arg_sensor0 -eq 1 ] ; then
		b_arg_sensor0=0;
		SNS_TYPE0=$arg;
		b_sensor0_set=1;
	fi
	if [ $b_arg_sensor1 -eq 1 ] ; then
		b_arg_sensor1=0;
		SNS_TYPE1=$arg;
		b_sensor1_set=1;
	fi
	if [ $b_arg_sensor2 -eq 1 ] ; then
		b_arg_sensor2=0;
		SNS_TYPE2=$arg;
		b_sensor2_set=1;
	fi
	if [ $b_arg_sensor3 -eq 1 ] ; then
		b_arg_sensor3=0;
		SNS_TYPE3=$arg;
		b_sensor3_set=1;
	fi

	if [ $b_arg_total_mem -eq 1 ]; then
		b_arg_total_mem=0;
		mem_total=$arg;

		if [ -z $mem_total ]; then
			echo "error: mem_total is null"
			exit;
		fi
	fi

	if [ $b_arg_os_mem -eq 1 ] ; then
		b_arg_os_mem=0;
		os_mem_size=$arg;

		if [ -z $os_mem_size ]; then
			echo "error: os_mem_size is null"
			exit;
		fi
	fi

	case $arg in
		"-h")
			load_usage;
			exit;
			;;
		"-i")
			b_arg_insmod=1;
			;;
		"-r")
			b_arg_remove=1;
			;;
		"-p")
			b_arg_perfomance=1;
			;;
		"-sensor0")
			b_arg_sensor0=1;
			;;
		"-sensor")
			b_arg_sensor0=1;
			;;
		"-sensor1")
			b_arg_sensor1=1;
			;;
		"-sensor2")
			b_arg_sensor2=1;
			;;
		"-sensor3")
			b_arg_sensor3=1;
			;;
		"-osmem")
			b_arg_os_mem=1;
			;;
		"-mem_total")
			b_arg_total_mem=1;
			;;
	esac
done

if [ $mem_total -le $(($dsp_mem_size + $os_mem_size + $reserved_mem_size)) ] ; then
	echo "error: dsp_mem[$dsp_mem_size] + os_mem[$os_mem_size] + reserved_mem[$reserved_mem_size] exceeds mem_total[$mem_total]"
	exit;
fi
calc_mmz;

if [ $b_arg_perfomance -eq 1 ] ; then
	vc_performance=1;
fi

if [ $b_arg_remove -eq 1 ]; then
	remove_ko;
fi

if [ $b_arg_insmod -eq 1 ]; then
	insert_ko;
fi
