#!/bin/sh

while true; do
	NOW_STATUS=$(cat "/sys/class/power_supply/BAT0/status")
	if [ $NOW_STATUS = Charging ]; then
		PRE_CHARGE=$(cat "/sys/class/power_supply/BAT0/charge_now")
		Flag=1
		if [ $(cat "/sys/class/power_supply/BAT0/voltage_now") -lt $(cat "/sys/class/power_supply/BAT0/voltage_min_design") ]; then
			if [ $(cat "/sys/class/power_supply/BAT0/current_now") -lt 1000000 ]; then
				notify-send \
					-u "critical" \
					-i "/home/cpthgli/.local/bin/low_battery_icon.png" \
					"Charge status is abnormal." \
					"/sys/class/power_supply/BAT0/current_now = "$(cat /sys/class/power_supply/BAT0/current_now)
			fi
		fi
	else
		if [ $NOW_STATUS = $PRE_STATUS ]; then
			:
		else
			notify-send \
				-u "critical" \
				-i "/home/cpthgli/.local/bin/plug_icon.png" \
				"Unpluged" \
				"/sys/class/power_supply/BAT0/status = "$(cat /sys/class/power_supply/BAT0/status)
		fi
		Flag=0
	fi
	PRE_STATUS=$NOW_STATUS

	sleep 1m

	if [ $Flag -eq 1 ]; then
		if [ $(cat "/sys/class/power_supply/BAT0/status") = Charging ]; then
			NOW_CHARGE=$(cat "/sys/class/power_supply/BAT0/charge_now")
			if [ $NOW_CHARGE -lt $PRE_CHARGE ]; then
				notify-send \
					-u "critical" \
					-i "/home/cpthgli/.local/bin/low_battery_icon.png" \
					"Charge status is abnormal." \
					"/sys/class/power_supply/BAT0/current_now = "$(cat /sys/class/power_supply/BAT0/current_now)
			fi
		fi
	fi
done
