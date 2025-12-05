#!/usr/bin/env sh
#
#                                           !!! WARNING !!!
#
# IF YOU FOUND THIS FILE IN A BOOT IMAGE YOU MUST KNOW THAT THIS FILE HAS BEEN GENERATED AUTOMATICALLY
# DO NOT CHANGE THIS FILE IN *ANY* WAY. THE ONLY WAY TO CHANGE THIS FILE IS TO USE EXTENSION MANAGER
#

cd "$(dirname "${0}")" || exit 1 # get to the script directory realiably in POSIX

PLATFORM_ID="ds3622xsp_42218"
EXTENSION_IDS="acpid2 boot-wait ing.processor ing.acpi-cpufreq ing.cpufreq_conservative ing.cpufreq_ondemand ing.cpufreq_performance ing.r8125 ing.sensor misc powersched reducelogs linux "
EXT_0_scripts_on_os_load="install-acpid.sh"
EXT_1_scripts_on_boot="boot-wait.sh"
EXT_2_kmod_files="processor.ko "
EXT_2_scripts_on_boot="check-processor.sh"
EXT_3_kmod_files="acpi-cpufreq.ko "
EXT_3_scripts_on_boot="check-acpi-cpufreq.sh"
EXT_4_kmod_files="cpufreq_conservative.ko "
EXT_4_scripts_on_boot="check-cpufreq_conservative.sh"
EXT_5_kmod_files="cpufreq_ondemand.ko "
EXT_5_scripts_on_boot="check-cpufreq_ondemand.sh"
EXT_6_kmod_files="cpufreq_performance.ko "
EXT_6_scripts_on_boot="check-cpufreq_performance.sh"
EXT_7_kmod_files="r8125.ko "
EXT_7_scripts_on_boot="check-r8125.sh"
EXT_8_kmod_files="nct6775.ko "
EXT_8_scripts_on_os_load="install.sh"
EXT_9_scripts_on_os_load="install-all.sh"
EXT_10_scripts_on_boot="install.sh"
EXT_11_scripts_on_os_load="install.sh"
EXT_12_scripts_on_os_load="install.sh"


# Gets indirect variable (needed as POSIX sh/busybox doesn't support arrays)
# Args: $1 ext number, $1 var name
_get_ext_var() {
  eval varval=\"\$EXT_$1_$2\"
  echo "${varval}"
}

# Run single script
# Args: $1 ext id | $2 script name
# Return: exit code from script
_run_script() {
  # the ./ part is crucial on newer versions of busybox - don't ask us why
  (cd "${1}" && PLATFORM_ID="${PLATFORM_ID}" EXT_ID="${1}" . "./${2}")
  return $?
}

# Executes script category for all extensions
# Args: $1 name of script action
_run_scripts() {
  echo ":: Executing \"${1}\" custom scripts ..."
  _ext_num=0
  _scr_exit=0
  _final_exit=0
  for name in ${EXTENSION_IDS}; do
    _script_name=$(_get_ext_var ${_ext_num} "scripts_$1")
    if [ ! -z ${_script_name} ]; then
      echo "Running \"${_script_name}\" for ${name}->$1"
      # arguments cannot be passed here due to https://github.com/koalaman/shellcheck/wiki/SC2240
      _run_script "${name}" "${_script_name}"
      _scr_exit=$?
      echo "Ran \"${_script_name}\" for ${name}->$1 - exit=${_scr_exit}"
      if [ $_scr_exit -ne 0 ]; then
        _final_exit=1
      fi
    fi
    _ext_num=$((_ext_num + 1))
  done

  if [ $_final_exit -ne 0 ]; then
    echo "ERROR: Some of the scripts failed! See above for any with exit != 0"
  fi

  echo ":: Executing \"${1}\" custom scripts ... [  OK  ]"
  exit $_final_exit
}

# Load all custom kernel modules
# Args: <no arguments>
_load_kmods() {
  echo ":: Loading kernel modules from extensions ..."
  _ext_num=0
  for name in ${EXTENSION_IDS}; do
    _kmods=$(_get_ext_var ${_ext_num} "kmod_files")
    _kmod_check=$(_get_ext_var ${_ext_num} "scripts_check_kmod")
    if [ ! -z ${_kmod_check} ]; then
      echo "Checking if kmods for ${name} should run using ${_kmod_check} script"
      if ! _run_script "${name}" "${_kmod_check}"; then
        echo "NOT loading kmods for ${name}"
        _ext_num=$((_ext_num + 1))
        continue
      fi
    fi

    _kmod_num=0
    for kmod_file in ${_kmods}; do
      _kmod_args=$(_get_ext_var ${_ext_num} "kmod_${_kmod_num}_args")
      echo "Loading kmod #${_kmod_num} \"${kmod_file}\" for ${name} (args: ${_kmod_args})"
      # shellcheck disable=SC2086
      _kmodname="${kmod_file::-3}"
      if [ $(lsmod | grep -w ${_kmodname} | wc -l) -eq 0 ]; then
        (cd "${name}" && insmod "${kmod_file}" ${_kmod_args})
        if [ $? -ne 0 ]; then
          echo "ERROR: kernel extensions \"${kmod_file}\" from ${name} failed to load"
          break
        fi
      else
        echo "Module ${_kmodname} already loaded"
      fi
      _kmod_num=$((_kmod_num + 1))
    done
    _ext_num=$((_ext_num + 1))
  done
  echo ":: Loading kernel modules from extensions ... [  OK  ]"
}

_set_MACs() {
  for N in $(ls /sys/class/net/ | grep eth); do
    MACR="$(cat /sys/class/net/${N}/address | sed 's/://g')"
    MACF="$(cat /proc/cmdline | sed 's/ /\n/g' | grep "mac$(expr ${N#eth} + 1)" | awk -F'=' '{print $2}')"
    if [ -n "${MACF}" ] && [ ! "${MACR,}" = "${MACF,}" ]; then
      MAC="${MACF:0:2}:${MACF:2:2}:${MACF:4:2}:${MACF:6:2}:${MACF:8:2}:${MACF:10:2}"
      /sbin/ip link set ${ETHX[${N}]} down
      /sbin/ip link set dev ${ETHX[${N}]} address ${MAC}
      /sbin/ip link set ${ETHX[${N}]} up
    fi
  done
}

case $1 in
load_kmods)
  _load_kmods
  _set_MACs
  ;;
on_boot_scripts)
  _run_scripts 'on_boot'
  ;;
on_os_load_scripts)
  _run_scripts 'on_os_load'
  ;;
*)
  if [ $# -lt 1 ]; then
    echo "Usage: $0 ACTION_NAME <...args>"
  else
    echo "Invalid ACTION_NAME=${1}"
  fi
  exit 1
  ;;
esac
