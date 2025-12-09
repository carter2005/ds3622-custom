#!/usr/bin/env ash


if [ $(mount | grep tmpRoot | wc -l) -gt 0 ]; then
  HASBOOTED="yes"
  echo "System passed junior"
else
  echo "System is booting"
  HASBOOTED="no"
fi

if [ "$HASBOOTED" = "yes" ]; then
  echo "Installing daemon for powersched"
  cp ./sed /tmpRoot/usr/bin/sed
  chmod +x /tmpRoot/usr/bin/sed
  SED_PATH='/tmpRoot/usr/bin/sed'

  echo "Installing powersched tools"
  cp -vf powersched /tmpRoot/usr/sbin/powersched
  chmod 755 /tmpRoot/usr/sbin/powersched
  # Clean old entries
  ${SED_PATH} -i '/\/usr\/sbin\/powersched/d' /tmpRoot/etc/crontab
  # Add line to crontab, execute each minute
  echo "*       *       *       *       *       root    /usr/sbin/powersched" >> /tmpRoot/etc/crontab
fi
