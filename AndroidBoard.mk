#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

#---------------------------------------
# Compile Partition Table
INSTALLED_PARTITION_TABLE_TARGET := $(PRODUCT_OUT)/stamp-install-partition-table-target

PARTITION_XML := $(LOCAL_PATH)/partition_table/partition-mbr.xml

$(INSTALLED_PARTITION_TABLE_TARGET): $(PARTITION_XML)

INTERNAL_PARTITION_TABLE_ARGS := -x $(PARTITION_XML) -o $(PRODUCT_OUT)/

MBR_BOOT_CODE := $(LOCAL_PATH)/partition_table/MBR_boot.bin
INTERNAL_PARTITION_TABLE_ARGS += -b $(MBR_BOOT_CODE)
$(INSTALLED_PARTITION_TABLE_TARGET): $(MBR_BOOT_CODE)

define build-partition-table-target
    @echo "Target Partition Table"
    $(hide) PATH=$(foreach p,$(INTERNAL_BOOTIMAGE_BINARY_PATHS),$(p):)$$PATH
      ./system/tools/pt-box/mkpart $(INTERNAL_PARTITION_TABLE_ARGS)
endef

$(INSTALLED_PARTITION_TABLE_TARGET):
	@rm -rf $@
	$(call pretty, "Install partition table: $@")
	$(call build-partition-table-target)
	@touch $@

#---------------------------------------
# Compile Linux Kernel
include device/generic/brillo/kernel.mk

INSTALLED_MODULES_FILES := \
    bnep.ko \
    hci_uart.ko \
    btbcm.ko \
    bluetooth.ko \
    brcmfmac.ko \
    brcmutil.ko \
    cfg80211.ko \
    rfkill.ko \
    snd-bcm2835.ko \
    snd-pcm.ko \
    snd-timer.ko \
    snd.ko \
    bcm2835-gpiomem.ko \
    bcm2835_wdt.ko \
    uio_pdrv_genirq.ko \
    uio.ko \
    i2c-dev.ko \
    fuse.ko \
    ipv6.ko

########################################
# Build Modules
KERNEL_MODULES_INSTALL := $(PRODUCT_OUT)/modules/lib/modules

define cp-modules
mkdir -p $(TARGET_OUT)/lib/modules
mdpath=`find $(KERNEL_MODULES_INSTALL) -type f -name modules.dep`;\
if [ "$$mdpath" != "" ];then\
mpath=`dirname $$mdpath`;\
for k in $(INSTALLED_MODULES_FILES); do \
ko=`find $$mpath/kernel -type f -name $$k`;\
for i in $$ko; do cp -rf $$i $(TARGET_OUT)/lib/modules; done;\
done; \
fi
endef

# Disable CCACHE_DIRECT so that header location changes are noticed.
define build_kernel
	CCACHE_NODIRECT="true" $(MAKE) -C $(TARGET_KERNEL_SRC) \
		O=$(realpath $(KERNEL_OUT)) \
		ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE="$(KERNEL_CROSS_COMPILE_WRAPPER)" \
		KCFLAGS="$(KERNEL_CFLAGS)" \
		KAFLAGS="$(KERNEL_AFLAGS)" \
		INSTALL_MOD_PATH=$(realpath $(PRODUCT_OUT)/modules) \
		$(1)
endef

$(KERNEL_MODULES_INSTALL): $(KERNEL_BIN)
	$(hide) echo "Installing kernel modules ..."
	# Since there may be no modules built, at least create the empty dir.
	mkdir -p $@
	if grep -q ^CONFIG_MODULES=y $(KERNEL_CONFIG) ; then \
		$(call build_kernel,modules_install) ; \
	fi

# Makes sure any built modules will be included in the system image build.
ALL_DEFAULT_INSTALLED_MODULES += $(KERNEL_MODULES_INSTALL)

# The list of dependencies for the final kernel.
KERNEL_DEPS := $(KERNEL_MODULES_INSTALL)

########################################
INSTALLED_BOOT_KERNEL_TARGET := $(TARGET_BOOT_OUT)/kernel.img
MKKNLIMG := $(TARGET_KERNEL_SRC)/scripts/mkknlimg

$(INSTALLED_BOOT_KERNEL_TARGET): $(KERNEL_BIN) $(KERNEL_DEPS) | $(ACP) $(MKKNLIMG)
	$(call pretty, "Install kernel DTB: $@")
	@rm -rf $@
	@rm -rf $(TARGET_BOOT_OUT)/*.dtb
	@rm -rf $(TARGET_BOOT_OUT)/overlays/*.dtb*
	@mkdir -p $(TARGET_BOOT_OUT)/overlays/
	$(ACP) -fp $(KERNEL_OUT)/arch/$(KERNEL_SRC_ARCH)/boot/dts/*.dtb $(TARGET_BOOT_OUT)/
	$(ACP) -fp $(KERNEL_OUT)/arch/$(KERNEL_SRC_ARCH)/boot/dts/overlays/*.dtb* $(TARGET_BOOT_OUT)/overlays/
	$(MKKNLIMG) $< $@
	$(cp-modules)

.PHONY: kernel
kernel: $(INSTALLED_BOOT_KERNEL_TARGET)
