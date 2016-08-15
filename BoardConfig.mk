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

#
# config.mk
#
# Product-specific compile-time difinitions.
#

BOARD_FLASH_BLOCK_SIZE := 512
BOARD_HAS_EXT4_RESERVED_BLOCKS := true
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true

# boot
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864  # 64MiB
BOARD_BOOTIMAGE_FILE_SYSTEM_TYPE := vfat

# recovery
#BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864 # 64MiB
#BOARD_RECOVERYIMAGE_FILE_SYSTEM_TYPE := vfat

# cache
#BOARD_CACHEIMAGE_PARTITION_SIZE := 134217728 # 128MiB
#BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4

# system
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1073741824 # 1GiB
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4

# userdata
BOARD_USERDATAIMAGE_PARTITION_SIZE := 134217728 # 128MiB
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
