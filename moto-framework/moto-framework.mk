#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

MOTO_FRAMEWORK_PATH := device/motorola/fogos/moto-framework

# Permissions
PRODUCT_COPY_FILES += \
    $(MOTO_FRAMEWORK_PATH)/permissions/com.motorola.frameworks.core.addon.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/com.motorola.frameworks.core.addon.xml \
    $(MOTO_FRAMEWORK_PATH)/permissions/moto-core_services.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/moto-core_services.xml \
    $(MOTO_FRAMEWORK_PATH)/permissions/moto-settings.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/moto-settings.xml \
    $(MOTO_FRAMEWORK_PATH)/permissions/moto-checkin.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/moto-checkin.xml \
    $(MOTO_FRAMEWORK_PATH)/permissions/motoaudioeffectsdk.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/motoaudioeffectsdk.xml

# Packages
PRODUCT_PACKAGES += \
    com.motorola.frameworks.core.addon \
    moto-core_services \
    moto-settings \
    moto-checkin \
    motoaudioeffectsdk \
    MotorolaSettingsProvider
