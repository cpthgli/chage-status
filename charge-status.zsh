#!/bin/zsh

THRESHOLD_CURRENT=1200000
THRESHOLD_CAPACITY_HIGH=85
THRESHOLD_CAPACITY_MIDDLE=50
THRESHOLD_CAPACITY_LOW=20

WORKSPACE_ROOT=~/Work/charge-status

APP_NAME=charge-status

get_status() {
	cat "/sys/class/power_supply/BAT0/status"
}
get_capacity() {
	cat "/sys/class/power_supply/BAT0/capacity"
}
get_charge_now() {
	cat "/sys/class/power_supply/BAT0/charge_now"
}
get_current_now() {
	cat "/sys/class/power_supply/BAT0/current_now"
}

unpluged_notify() {
	notify-send \
		-u "normal" \
		-a $APP_NAME \
		-i $WORKSPACE_ROOT"/icons/plug_icon.png" \
		"Unpluged." \
		"/sys/class/power_supply/BAT0/status = "$(get_status)
}
low_current_notify() {
	notify-send \
		-u "critical" \
		-a $APP_NAME \
		-i $WORKSPACE_ROOT"/icons/battery_error.png" \
		"Low Current." \
		"/sys/class/power_supply/BAT0/current_now = "$(get_current_now)
}
decrease_charge_notify() {
	notify-send \
		-u "critical" \
		-a $APP_NAME \
		-i $WORKSPACE_ROOT"/icons/battery_error.png" \
		"Decrease Charge."
}
low_battery_notify() {
	notify-send \
		-u "critical" \
		-a $APP_NAME \
		-i $WORKSPACE_ROOT"/icons/low_battery_icon.png" \
		"Low Battery." \
		"/sys/class/power_supply/BAT0/capacity = "$(get_capacity)
}
middle_battery_notify() {
	notify-send \
		-u "normal" \
		-a $APP_NAME \
		-i $WORKSPACE_ROOT"/icons/middle_battery_icon.png" \
		"Middle Battery." \
		"/sys/class/power_supply/BAT0/capacity = "$(get_capacity)
}

PRE_STATUS=$(get_status)
PRE_CHARGE=$(get_charge_now)
CAPACITY_MIDDLE_FLAG=1
CAPACITY_LOW_FLAG=1
while; do
	NOW_STATUS=$(get_status)
	NOW_CHARGE=$(get_charge_now)
	echo "PRE_STATUS" $PRE_STATUS
	echo "NOW_STATUS" $NOW_STATUS
	echo "PRE_CHARGE" $PRE_CHARGE
	echo "NOW_CHARGE" $NOW_CHARGE
	echo "CAPACITY_LOW_FLAG" $CAPACITY_LOW_FLAG
	echo "CAPACITY_MIDDLE_FLAG" $CAPACITY_MIDDLE_FLAG

	if [ $NOW_STATUS = Charging ]; then

		if [ $(get_current_now) -lt $THRESHOLD_CURRENT ]; then
			if [ $(get_capacity) -lt $THRESHOLD_CAPACITY_HIGH ]; then
				low_current_notify
			fi
		fi

		if [ $NOW_CHARGE -lt $PRE_CHARGE ]; then
			decrease_charge_notify
		fi

	else

		CAPACITY=$(get_capacity)
		if [ $CAPACITY -le $THRESHOLD_CAPACITY_MIDDLE ]; then
			if [ $CAPACITY_MIDDLE_FLAG -eq 1 ]; then
				middle_battery_notify
				CAPACITY_MIDDLE_FLAG=0
			fi
		else
			CAPACITY_MIDDLE_FLAG=1
		fi

		if [ $CAPACITY -le $THRESHOLD_CAPACITY_LOW ]; then
			if [ $CAPACITY_LOW_FLAG -eq 1 ]; then
				low_battery_notify
				CAPACITY_LOW_FLAG=0
			fi
		else
			CAPACITY_LOW_FLAG=1
		fi

		if [ $PRE_STATUS = Charging ]; then
			unpluged_notify
		fi

	fi

	PRE_STATUS=$NOW_STATUS
	PRE_CHARGE=$NOW_CHARGE

	sleep 1m

done
