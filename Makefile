TARGET = iphone:clang:16.5:16.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DockReflections16
DockReflections16_FILES = Tweak.xm
DockReflections16_CFLAGS = -fobjc-arc -Wall -Wextra
DockReflections16_FRAMEWORKS = UIKit QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
