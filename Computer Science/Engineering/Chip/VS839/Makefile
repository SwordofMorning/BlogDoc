#
# @file    Makefile
# @author  Visinex Software Group
# @date    2021-06-02
# @version v1.0
# @Copyright (c) 2021 Shanghai Visinex Technologies Co., Ltd. All rights reserved.
# @description
#    Top level Makefile
#
#    TODO: Define top level libraries path for using in common
#
#    Package adding guide:
#      1) Create package makefile follow mk/osal.mk
#      2) Include the makefile file you just created to this file
#      3) Add package name to PACKAGES list
#

TOP_DIR := $(shell pwd)
BUILD_DIR := $(TOP_DIR)/build
MK_DIR := $(TOP_DIR)/mk
IMAGE_PATH	:= $(TOP_DIR)/image
ROOTFS_PATH := $(IMAGE_PATH)/rootfs
STRIP_ROOTFS_PATH := $(IMAGE_PATH)/strip_rootfs
DEV_PATH := $(ROOTFS_PATH)/dev
HFILE_EXPORTS_PATH := $(TOP_DIR)
LIBRARY_EXPORTS_PATH := $(TOP_DIR)/vs-mp/lib
THIRD_PARTY_PATH := /daily-build/third-party

MAJOR_VER ?= 0
MINOR_VER ?= 0
PATCH_VER ?= 0
BUILD_ID ?= 20
# Common CFLAGS #
MP_CFLAGS += -DMAJOR_VER=$(MAJOR_VER) -DMINOR_VER=$(MINOR_VER) -DPATCH_VER=$(PATCH_VER) -DBUILD_ID=$(BUILD_ID)
MP_CFLAGS += -Wno-date-time -fstack-protector-strong
MP_LDFLAGS += -Wl,-z,relro -Wl,-z,noexecstack -Wl,-z,now,-s

MP_LIBS_CFLAGS := -Wall -fPIC
MP_EXEC_CFLAGS := -fPIE  -s
MP_LIBS_LDFLAGS :=
MP_EXEC_LDFLAGS := -pie

CHIP_TYPE=carina
SUPPORT_CHIP=CARINA
SCRIPT_TYPE=vs8x9
MP_CFLAGS += -DVS_CARINA

# Currently used by u-boot image generation
BOARD_TYPE ?= ci03

# XJT Begin: FS Overlay功能
FS_OVERLAY_PATH := $(TOP_DIR)/fs-overlay
export FS_OVERLAY_PATH
# XJT End: FS Overlay功能

FLASH_TYPE_SPI_NOR := spi-nor
FLASH_TYPE_SPI_NAND := spi-nand
FLASH_TYPE_NAND := nand
FLASH_TYPE_EMMC := emmc
# Default: emmc
FLASH_TYPE ?= emmc

FLASH_PAGE_SIZE ?= 2048
# Flash erase block size
FLASH_BLOCK_SIZE ?= 65536
# Flash oob size
FLASH_OOB_SIZE ?= 128

# ROOTFS_TYPE and ROOTFS_SIZE can be passed from make args
# check help for more info
ROOTFS_TYPE ?= ext4
ROOTFS_SIZE ?= 512MiB

IMG_MAX_SIZE ?= 0
BOOT_SCREEN ?= 0

export TOP_DIR
export BUILD_DIR
export HFILE_EXPORTS_PATH
export LIBRARY_EXPORTS_PATH
export MP_CFLAGS
export MP_LDFLAGS
export MP_LIBS_CFLAGS
export MP_EXEC_CFLAGS
export MP_EXEC_LDFLAGS
export MP_LIBS_LDFLAGS
export CHIP_TYPE
export FLASH_TYPE
export FLASH_PAGE_SIZE
export ROOTFS_TYPE
export BOARD_TYPE
export ROS_SUPPORT
export IMG_MAX_SIZE
export BOOT_SCREEN

LINUX_IMAGE_PATH := $(IMAGE_PATH)/linux_$(ROOTFS_TYPE)


default: all

# Include package makefiles, common.mk must be the first one
include $(MK_DIR)/common.mk
include $(MK_DIR)/atf.mk
include $(MK_DIR)/uboot.mk
include $(MK_DIR)/busybox.mk
include $(MK_DIR)/osal.mk
include $(MK_DIR)/dspfw.mk
include $(MK_DIR)/ispsensor.mk
include $(MK_DIR)/sample.mk
include $(MK_DIR)/sign.mk
include $(MK_DIR)/ros.mk

export VS_KBUILD_EXTRA_SYMBOLS

# Include package utils, must be after the package makefiles
include $(MK_DIR)/pkgutils.mk

# # Define the package name list
# PACKAGES = \
# 	atf \
# 	uboot \
# 	busybox \
# 	vs-osal \
# 	vs-dspfw \
# 	vs-ispsensor \
# 	vs-sample \
# 	vs-sign \
# 	ros

# Define the package name list
PACKAGES = \
	atf \
	uboot \
	busybox \
	vs-osal \
	vs-ispsensor \
	vs-sample \
	vs-sign \
	ros

PACKAGES_CLEAN := $(addsuffix -clean,$(PACKAGES))

.PHONY: all
.NOTPARALLEL: all
all: prepare linux $(PACKAGES) rootfs boot-screen
	@echo ""
	@echo "Completed the build."
	@echo ""

linux: linux-common

.PHONY: clean
clean: linux-clean $(PACKAGES_CLEAN)
	@echo "Cleaned the build."

linux-clean: linux-clean-common

.PHONY: distclean
distclean: clean
	rm -rf $(BUILD_DIR)
	rm -rf $(IMAGE_PATH)
	@echo "Removed all build artifacts."

prepare:
	@echo "Preparing environment."
	@mkdir $(BUILD_DIR) -p
	@mkdir $(IMAGE_PATH) -p
	@mkdir $(LINUX_IMAGE_PATH) -p
	@mkdir $(ROOTFS_PATH) -p
	@mkdir $(HFILE_EXPORTS_PATH) -p
	@mkdir $(LIBRARY_EXPORTS_PATH) -p
	@cd $(ROOTFS_PATH)/ && mkdir bin dev lib lib/include lib/modules lib/firmware sbin usr usr/bin usr/lib usr/sbin proc sys -p


# Create package targets
$(foreach pkg,$(PACKAGES),$(eval $(call create-package-target,$(pkg),$(call lowercase,$(subst vs-,,$(pkg))),$(call uppercase,$(subst -,_,$(pkg))))))

# Build rootfs
.PHONY: rootfs
rootfs:
	@if [[ ! -d $(ROOTFS_PATH) ]]; then \
		mkdir $(ROOTFS_PATH) -p; \
		cd $(ROOTFS_PATH)/ && mkdir bin dev lib lib/include lib/modules lib/firmware sbin usr usr/bin usr/lib usr/sbin proc sys -p; \
	fi
	@if [[ "$(BUSYBOX_BUILD_PATH)" != "" ]] && [[ -d $(BUSYBOX_BUILD_PATH)/_install/ ]]; then \
		$(CP) $(BUSYBOX_BUILD_PATH)/_install/* $(ROOTFS_PATH)/ -rapf; \
		$(CP) $(BUSYBOX_BUILD_PATH)/scripts/$(SCRIPT_TYPE)/etc $(ROOTFS_PATH)/ -rapf; \
		rm $(IMAGE_PATH)/tools -rf; \
		$(CP) $(ROOTFS_PATH)/usr/bin $(IMAGE_PATH)/tools -rapf; \
		for del_file in `ls $(BUSYBOX_BUILD_PATH)/_install/usr/bin`; \
		do \
			rm $(IMAGE_PATH)/tools/$${del_file} -rf; \
		done ;\
		rm $(IMAGE_PATH)/tools/sample -rf; \
	fi

	@if [[ ! -e $(ROOTFS_PATH)/init ]]; then \
		cd $(ROOTFS_PATH) && ln -s sbin/init init; \
	fi
	@if [[ -d $(ROOTFS_PATH)/lib ]]; then \
		$(CP) $(CROSS_COMPILE_ROOT_PATH)/aarch64-linux-gnu/libc/lib/*.so.* $(ROOTFS_PATH)/lib/ -rfap; \
		$(CP) $(CROSS_COMPILE_ROOT_PATH)/aarch64-linux-gnu/libc/lib/*.so $(ROOTFS_PATH)/lib/ -rfap; \
		mkdir $(ROOTFS_PATH)/toolchain_lib -p; \
		$(CP) $(CROSS_COMPILE_ROOT_PATH)/aarch64-linux-gnu/libc/lib/*.so.* $(ROOTFS_PATH)/toolchain_lib -rfap; \
		$(CP) $(CROSS_COMPILE_ROOT_PATH)/aarch64-linux-gnu/libc/lib/*.so $(ROOTFS_PATH)/toolchain_lib -rfap; \
		rm $(ROOTFS_PATH)/toolchain_lib/libstdc++.so.6.0.24-gdb.py -rf; \
		rm $(ROOTFS_PATH)/lib/libstdc++.so.6.0.24-gdb.py -rf; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/*.so $(ROOTFS_PATH)/lib/ -rfap; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/libasound.so.2.0.0 $(ROOTFS_PATH)/lib/ -rfap; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/libasound.so.2 $(ROOTFS_PATH)/lib/ -rfap; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/nn/* $(ROOTFS_PATH)/lib/ -rfap; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/../bin/* $(ROOTFS_PATH)/usr/bin/ -rfap; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/../bin/* $(IMAGE_PATH)/tools -rfap; \
		$(CP) $(LIBRARY_EXPORTS_PATH)/modules/*.ko $(ROOTFS_PATH)/lib/modules/ -rfap; \
	fi

	@if [[ ! -d $(ROOTFS_PATH)/lib64 ]]; then \
		cd $(ROOTFS_PATH) && ln -s lib lib64; \
	fi
	@cd $(ROOTFS_PATH)/ && chmod 777 -R bin lib sbin usr etc init proc sys linuxrc

	rm $(STRIP_ROOTFS_PATH) -rf;
	$(CP) $(ROOTFS_PATH) $(STRIP_ROOTFS_PATH) -rfap;
	rm $(ROOTFS_PATH)/toolchain_lib -rf;
	$(CROSS_COMPILE_PATH)/aarch64-linux-gnu-strip $(STRIP_ROOTFS_PATH)/toolchain_lib/*.so*;
	$(CROSS_COMPILE_PATH)/aarch64-linux-gnu-strip $(STRIP_ROOTFS_PATH)/lib/*.so*;
	$(CROSS_COMPILE_PATH)/aarch64-linux-gnu-strip --strip-unneeded $(STRIP_ROOTFS_PATH)/lib/modules/*;
	rm $(IMAGE_PATH)/lib $(IMAGE_PATH)/ko  $(IMAGE_PATH)/sample  $(IMAGE_PATH)/firmware $(IMAGE_PATH)/app -rf;
	mv $(STRIP_ROOTFS_PATH)/lib $(IMAGE_PATH);
	mv $(IMAGE_PATH)/lib/firmware $(IMAGE_PATH)
	mv $(IMAGE_PATH)/lib/modules $(IMAGE_PATH)/ko
	-mv $(STRIP_ROOTFS_PATH)/usr/bin/sample $(IMAGE_PATH)
	-mv $(STRIP_ROOTFS_PATH)/usr/bin/app $(IMAGE_PATH)
	@for del_file in `ls $(STRIP_ROOTFS_PATH)/toolchain_lib`; \
	do  \
		rm $(IMAGE_PATH)/lib/$${del_file} -rf ;\
	done
	mv $(STRIP_ROOTFS_PATH)/toolchain_lib  $(STRIP_ROOTFS_PATH)/lib
	@for del_file in `ls $(IMAGE_PATH)/tools`; \
	do  \
		rm $(STRIP_ROOTFS_PATH)/usr/bin/$${del_file} -rf; \
	done
	$(CP) $(LIBRARY_EXPORTS_PATH)/firmware $(STRIP_ROOTFS_PATH)/lib/ -rfap

	# XJT Begin: Fs-overlay
	@echo "Applying fs-overlay..."
	@if [[ -d $(FS_OVERLAY_PATH) ]]; then \
		echo "Copying fs-overlay files to rootfs..."; \
		$(CP) $(FS_OVERLAY_PATH)/* $(STRIP_ROOTFS_PATH)/ -rfap; \
		echo "fs-overlay applied successfully."; \
	else \
		echo "No fs-overlay directory found, skipping..."; \
	fi
	# XJT End: Fs-overlay

	@echo "Making rootfs image, ROOTFS_TYPE: $(ROOTFS_TYPE)"
	@if [[ "$(ROOTFS_TYPE)" == "ext4" ]]; then \
		make_ext4fs -l $(ROOTFS_SIZE) -s $(LINUX_IMAGE_PATH)/rootfs_ext4.simg $(STRIP_ROOTFS_PATH); \
		if [[ $(IMG_MAX_SIZE) -ne 0 ]]; then \
			mkdir $(LINUX_IMAGE_PATH)/rootfs_ext4 -p; \
			rm -rf $(LINUX_IMAGE_PATH)/rootfs_ext4/*; \
			mv $(LINUX_IMAGE_PATH)/rootfs_ext4.simg $(LINUX_IMAGE_PATH)/rootfs_ext4; \
			cd $(LINUX_IMAGE_PATH)/rootfs_ext4; \
			simg2simg rootfs_ext4.simg rootfs_ext4.simg.part $(IMG_MAX_SIZE); \
			rm $(LINUX_IMAGE_PATH)/rootfs_ext4/rootfs_ext4.simg; \
		else \
			rm -rf $(LINUX_IMAGE_PATH)/rootfs_ext4; \
		fi \
	elif [[ "$(ROOTFS_TYPE)" == "jffs2" ]]; then \
		mkfs.jffs2 -n -p -e $(FLASH_BLOCK_SIZE) --root=$(STRIP_ROOTFS_PATH) -o $(LINUX_IMAGE_PATH)/rootfs_jffs2.img; \
	elif [[ "$(ROOTFS_TYPE)" == "yaffs2" ]]; then \
		../image/tools/mkyaffs2 -p $(FLASH_PAGE_SIZE) -s $(FLASH_OOB_SIZE) $(STRIP_ROOTFS_PATH) $(LINUX_IMAGE_PATH)/rootfs_yaffs2.img; \
	elif [[ "$(ROOTFS_TYPE)" == "ubifs" ]]; then \
		$(TOP_DIR)/vs-tools/package-tool/ubifs_script/make_ubifs_img.sh \
			$(FLASH_PAGE_SIZE) $(FLASH_BLOCK_SIZE) $(STRIP_ROOTFS_PATH) $(ROOTFS_SIZE) $(LINUX_IMAGE_PATH); \
	elif [[ "$(ROOTFS_TYPE)" == "initramfs" ]]; then \
		true; \
	else \
		echo Unsupported ROOTFS_TYPE: ${ROOTFS_TYPE}; exit 1; \
	fi
	@echo "  Done"
	@echo "Completed building rootfs."

.PHONY: rootfs-clean
rootfs-clean:
	rm -rf $(ROOTFS_PATH)

.PHONY: boot-screen
boot-screen:
	@if [[ "$(BOOT_SCREEN)" == "1" ]]; then \
		$(call ins_file,$(TOP_DIR)/vs-tools/package-tool/boot_screen/boot_screen.bin,$(LINUX_IMAGE_PATH)); \
	fi

help:
	@echo ""
	@echo "usage: ${MAKE} [OPTIONS] [TARGET]"
	@echo ""
	@echo "Supported Options:"
	@echo "  V=1                Verbose build"
	@echo "  force=1            Force update module files"
	@echo "  FLASH_TYPE=[spi-nor spi-nand nand emmc] Default type is emmc"
	@echo "  FLASH_PAGE_SIZE=<size> Flash page size, default is 2048"
	@echo "  FLASH_BLOCK_SIZE=<size> Flash erase block size, default is 65536"
	@echo "  FLASH_OOB_SIZE=<size> Flash oob/spare size, default is 128"
	@echo "  ROOTFS_TYPE=[ext4 jffs2 yaffs2 ubifs initramfs] Default type is ext4"
	@echo "  ROOTFS_SIZE=<size> Size of rootfs partition, default is 512MiB"
	@echo "  BOOT_SCREEN=1      Support boot screen feature"
	@echo "  ROS_SUPPORT=1      Compiling ros library, default is ROS_SUPPORT=0"
	@echo ""
	@echo "Supported Targets: $(TOP_DIR)"
	@echo "  prepare-source     Setup the build source"
	@echo "  all                Build all individual binaries/libraries"
	@for d in $(PACKAGES); do \
		printf "  %-18s Build %s module\n" $$d $$d; \
	done
	@echo "  linux              Build the linux"
	@echo "  rootfs             Build the rootfs"
	@echo "  clean              Clean the build"
	@echo "  distclean          Remove all build artifacts"
	@for d in $(PACKAGES); do \
		printf "  %-18s Clean %s build\n" $$d-clean $$d; \
	done
	@echo "  linux-clean        Clean the linux build"
	@echo "  rootfs-clean       Clean the rootfs build"
	@echo ""
