THEOS_DEVICE_IP = 192.168.1.3
TARGET = iphone:clang:13.0:13.0
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Oberon

Oberon_FILES = Tweak.xm
Oberon_CFLAGS = -fobjc-arc
Oberon_FRAMEWORKS = AVFoundation
Oberon_PRIVATE_FRAMEWORKS = SpringBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"