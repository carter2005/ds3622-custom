#!/usr/bin/env sh
#
# Copyright (C) 2025 AuxXxilium <https://github.com/AuxXxilium>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

install_addon() {
  echo "Installing addon reducelogs - ${1}"

  addblocklog() {
    [ -z "${1}" ] && return 1
    FNAME="f_$(echo "${1}" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/.*/\L&/' | cut -c 1-30)"
    REGEX="${1}"
    mkdir -p "${SYSLOG_NG_PATH}"
        sed -i "/${FNAME}/d" "${SYSLOG_NG_PATH}/ARC.conf" 2>/dev/null
    # shellcheck disable=SC2059
    printf "filter ${FNAME} { match(\"${REGEX}\" value(\"MESSAGE\")); };\nlog { source(src); filter(${FNAME}); flags(final); };\n" >>"${SYSLOG_NG_PATH}/ARC.conf"
    chown system:log "${SYSLOG_NG_PATH}/ARC.conf"
    chmod 644 "${SYSLOG_NG_PATH}/ARC.conf"

    for D in not2kern not2msg; do
      mkdir -p "${SYSLOG_NG_PATH}/include/${D}"
      sed -i "/${FNAME}/d" "${SYSLOG_NG_PATH}/include/${D}/ARC_${D}.conf" 2>/dev/null
      echo "and not filter(${FNAME})" >>"${SYSLOG_NG_PATH}/include/${D}/ARC_${D}.conf"
      chown system:log "${SYSLOG_NG_PATH}/include/${D}/ARC_${D}.conf"
      chmod 644 "${SYSLOG_NG_PATH}/include/${D}/ARC_${D}.conf"
    done

    # systemctl restart syslog-ng
  }

  delblocklog() {
    [ -z "${1}" ] && return 1
    if echo "all *" | grep -wq "${1}"; then
      rm -f "${SYSLOG_NG_PATH}/ARC.conf"
      for D in not2kern not2msg; do
        rm -f "${SYSLOG_NG_PATH}/include/${D}/ARC_${D}.conf"
      done
    else
      FNAME="f_$(echo "${1}" | sed 's/[^a-zA-Z0-9]/_/g' | sed 's/.*/\L&/' | cut -c 1-30)"
      sed -i "/${FNAME}/d" "${SYSLOG_NG_PATH}/ARC.conf" 2>/dev/null
      for D in not2kern not2msg; do
        sed -i "/${FNAME}/d" "${SYSLOG_NG_PATH}/include/${D}/ARC_${D}.conf" 2>/dev/null
      done
    fi
  }

  getblocklog() {
    grep -Eo "filter.*match.*" "${SYSLOG_NG_PATH}/ARC.conf" 2>/dev/null | sed 's/filter \(.*\) { match(\(.*\) value("MESSAGE")); };/\1=\2/'
  }

  # syslog-ng
  ROOT_PATH="/tmpRoot"
  SYSLOG_NG_PATH="${ROOT_PATH}/etc/syslog-ng/patterndb.d"
  delblocklog "*"
  addblocklog "synobios get empty ttyS current"
  addblocklog "telnet/tcp: bind: Address already in use"
  addblocklog "Invalid parameter"
  addblocklog "Failed to get"
  addblocklog "Failed to load"
  addblocklog "Failed to check"
  addblocklog "Failed to update"
  addblocklog "fail to get all"
  addblocklog "Can't get sata chip name"
  addblocklog "redundant_power_chec"
  addblocklog "fan/fan_"
  addblocklog "fan/fan_"
  addblocklog "plugin_action"
  addblocklog "package_action"
  addblocklog "No NVIDIA"
  addblocklog "ioctl device failed"

  # syno-dump-core
  SH_FILE="/tmpRoot/usr/syno/sbin/syno-dump-core.sh"
  [ ! -f "${SH_FILE}.bak" ] && cp -pf "${SH_FILE}" "${SH_FILE}.bak"
  printf '#!/usr/bin/env sh\nexit 0\n' >"${SH_FILE}"
  
  # scemd  
  sed -i 's#/var/log#/run#g' /tmpRoot/etc/syslog-ng/patterndb.d/scemd.conf
  sed -i 's#info#emerg#g'    /tmpRoot/etc/syslog-ng/patterndb.d/scemd.conf
  sed -i 's#/var/log#/run#g' /tmpRoot/etc.defaults/syslog-ng/patterndb.d/scemd.conf
  sed -i 's#info#emerg#g'    /tmpRoot/etc.defaults/syslog-ng/patterndb.d/scemd.conf
  sed -i 's#/var/log#/run#g' /tmpRoot/etc/logrotate.d/scemd
  sed -i 's#/var/log#/run#g' /tmpRoot/etc.defaults/logrotate.d/scemd
}


if [ $(mount | grep tmpRoot | wc -l) -gt 0 ]; then
  HASBOOTED="yes"
  echo "System passed junior"
else
  echo "System is booting"
  HASBOOTED="no"
fi

if [ "$HASBOOTED" = "yes" ]; then
  echo "Installing reducelogs"
  install_addon "late"  
fi
