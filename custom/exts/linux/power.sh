#!/bin/bash

echoc()
{
    case $1 in
        red)    color=31;;
        green)  color=32;;
        yellow) color=33;;
        blue)   color=34;;
        purple) color=35;;
        white)  color=37;;
        *)      color=36;;
    esac
    echo -e "\033[;${color}m$2\033[0m"
}

function setup_cpu_governor_once()
{
    local governor_lists=$1

    for ((cpu_id=0;cpu_id<$cpu_count;cpu_id++));do
        echoc green "cpu: $cpu_id"
        for governor in $governor_lists;do
            available_governor=`cat /sys/devices/system/cpu/cpu$cpu_id/cpufreq/scaling_available_governors | grep -Eo $governor`
            if [ "$available_governor" = "" ];then
                continue
            else
                echoc purple "    setting to $governor mode"
                echo $governor > /sys/devices/system/cpu/cpu$cpu_id/cpufreq/scaling_governor
                break
            fi
        done
    done
}

function dump_cpu_state()
{
    echoc yellow "current CPU state"
    echoc green "ID\tfreq\t\tcurrent governor\tavailable_governor"
    for ((cpu_id=0;cpu_id<$cpu_count;cpu_id++));do
        current_freq=`cat /sys/devices/system/cpu/cpu$cpu_id/cpufreq/scaling_cur_freq`
        current_governor=`cat /sys/devices/system/cpu/cpu$cpu_id/cpufreq/scaling_governor`
        available_governor=`cat /sys/devices/system/cpu/cpu$cpu_id/cpufreq/scaling_available_governors`
        echoc purple "$cpu_id\t$current_freq\t\t$current_governor\t\t$available_governor"
    done
}


cpu_count=`cat /proc/cpuinfo | grep processor | wc -l`

if [ $# -eq 0 ]; then
    dump_cpu_state
elif [ $# -eq 1 ]; then
    setup_cpu_governor_once $1
    sleep 1
    dump_cpu_state
fi

