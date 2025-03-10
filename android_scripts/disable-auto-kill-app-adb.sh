#!/bin/sh
	
# set disable auto kill apps
adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
adb shell settings put global settings_enable_monitor_phantom_procs false

# check max proses background
adb shell "/system/bin/device_config get activity_manager max_phantom_processes"
