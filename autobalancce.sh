#!/bin/bash

eth0executado=false
wlan0executado=false

while true;
do

	contador="1"
	interface=()
	status=()

	sleep 5

	while true;
	do
		dispositivo=($(ip addr show | grep "^${contador}: "))
		placa=$(echo ${dispositivo[1]} | sed "s/://")
		estado=${dispositivo[8]}
		interface=("${interface[@]}" "${placa}")
		status=("${status[@]}" "${estado}")
		let "contador+=1" 
		if [ "$dispositivo" = "" ]
		then
			break
		fi
	done

	for ((x=0; x < ${#interface[*]}; x++)) ; do 
		if [ "${interface[$x]}" != "lo" ]
		then
	 		#echo ${interface[$x]} ${status[$x]}
			if [ "${interface[$x]}" = "eth0" ]
			then
				if [ "${status[$x]}" = "UP" ]
				then
					eth0status=true
				else
					eth0status=false
				fi
			fi

			if [ "${interface[$x]}" = "eth0" ]
			then
				 if [ "${status[$x]}" = "UP" ]
                                then
                                        wlan0status=true
                                else
                                        wlan0status=false
                                fi

			fi
		fi
	done

	if [ $eth0status = true -o $wlan0status = true ]
	then
		if [ $eth0executado = false ];
		then
			sudo route del default dev eth0
			sudo route add default gw 192.168.0.1 dev eth0 metric 202
			sudo route del -net 192.168.0.0 gw 0.0.0.0 netmask 255.255.255.0 dev eth0
			sudo route add -net 192.168.0.0 netmask 255.255.255.0 dev eth0 metric 202

			sudo route del default dev wlan0
			sudo route add default gw 192.168.0.1 dev wlan0 metric 303
			sudo route del -net 192.168.0.0 gw 0.0.0.0 netmask 255.255.255.0 dev wlan0
			sudo route add -net 192.168.0.0 netmask 255.255.255.0 dev wlan0 metric 303
			
			sudo /etc/init.d/networking restart
			
			eth0executado=true
			wlan0executado=false
		fi

	elif [ $eth0status = false -o $wlan0status = true ]
	then
		if [ $wlan0executado = false ];
		then
			sudo route del default dev eth0
			sudo route add default gw 192.168.0.1 dev eth0 metric 303
			sudo route del -net 192.168.0.0 gw 0.0.0.0 netmask 255.255.255.0 dev eth0
			sudo route add -net 192.168.0.0 netmask 255.255.255.0 dev eth0 metric 303

			sudo route del default dev wlan0
			sudo route add default gw 192.168.0.1 dev wlan0 metric 202
			sudo route del -net 192.168.0.0 gw 0.0.0.0 netmask 255.255.255.0 dev wlan0
			sudo route add -net 192.168.0.0 netmask 255.255.255.0 dev wlan0 metric 202
			
			sudo /etc/init.d/networking restart
			
			wlan0executado=true
			eth0executado=false
		fi
	fi

	sleep 5

	unset dispositivo
	unset placa
	unset estado
	unset interface
	unset status
	unset contador
	unset interface
	unset status
	unset wlan0status
	unset eth0status

done
