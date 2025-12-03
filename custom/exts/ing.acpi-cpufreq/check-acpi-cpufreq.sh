#
# Checking modules is loaded
#

echo -n "Loading module acpi-cpufreq -> "
[ `/sbin/lsmod | grep -i acpi-cpufreq | wc -l` -gt 0 ] && echo "Module acpi-cpufreq loaded succesfully" || echo "Module acpi-cpufreq is not loaded"
