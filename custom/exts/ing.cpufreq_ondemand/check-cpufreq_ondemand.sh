#
# Checking modules is loaded
#

echo -n "Loading module cpufreq_ondemand -> "
[ `/sbin/lsmod | grep -i cpufreq_ondemand | wc -l` -gt 0 ] && echo "Module cpufreq_ondemand loaded succesfully" || echo "Module cpufreq_ondemand is not loaded"
