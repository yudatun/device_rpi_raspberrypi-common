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
    rfkill.ko \
    cfg80211.ko \
    mac80211.ko \
    rtl8xxxu.ko

define mv-modules
mkdir -p $(TARGET_OUT)/lib/modules
mdpath=`find $(KERNEL_MODULES_INSTALL) -type f -name modules.dep`;\
if [ "$$mdpath" != "" ];then\
mpath=`dirname $$mdpath`;\
for k in $(INSTALLED_MODULES_FILES); do \
ko=`find $$mpath/kernel -type f -name $$k`;\
for i in $$ko; do mv $$i $(TARGET_OUT)/lib/modules; done;\
done; \
fi
endef

INSTALLED_BOOT_KERNEL_TARGET := $(TARGET_BOOT_OUT)/kernel.img
MKKNLIMG := $(TARGET_KERNEL_SRC)/scripts/mkknlimg

$(INSTALLED_BOOT_KERNEL_TARGET): $(KERNEL_IMAGE) $(KERNEL_DEPS) | $(ACP) $(MKKNLIMG)
	$(call pretty, "Install kernel DTB: $@")
	@rm -rf $@
	@rm -rf $(TARGET_BOOT_OUT)/*.dtb
	@rm -rf $(TARGET_BOOT_OUT)/overlays/*.dtb*
	@mkdir -p $(TARGET_BOOT_OUT)/overlays/
	$(ACP) -fp $(KERNEL_OUT)/arch/$(KERNEL_SRC_ARCH)/boot/dts/*.dtb $(TARGET_BOOT_OUT)/
	$(ACP) -fp $(KERNEL_OUT)/arch/$(KERNEL_SRC_ARCH)/boot/dts/overlays/*.dtb* $(TARGET_BOOT_OUT)/overlays/
	$(MKKNLIMG) $< $@
	$(mv-modules)

.PHONY: kernel
kernel: $(INSTALLED_BOOT_KERNEL_TARGET)
