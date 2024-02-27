#!/bin/bash

# Define the log file name as a variable
LOG_FILE_NAME="/var/log/setmtu.log"

# Function to log message with date prefix to console and log file
log_message() {
    local datetime=$(date '+%Y%m%d %H:%M:%S')
    # Check if we have an argument or if we're receiving something from a pipe
    if [ "$#" -eq 0 ]; then
        # Reading from standard input (piped input)
        while IFS= read -r line; do
            echo "$datetime $line" | tee -a "$LOG_FILE_NAME"
        done
    else
        # Argument provided directly
        local message="$*"
        echo "$datetime $message" | tee -a "$LOG_FILE_NAME"
    fi
}

# Ensure the log file exists and is writable
touch "$LOG_FILE_NAME"
chmod 664 "$LOG_FILE_NAME"

log_message "Starting script"

check_interface_up() {
    local interface=$1
    # Check if the interface is in the up state by looking for "UP" flag
    if ip link show "$interface" | grep -qw "UP"; then
        return 0 # Success, interface is operational
    else
        return 1 # Failure, interface is not operational
    fi
}

max_attempts=100
attempt=1

log_message "Check if ppp0 is UP..."
while ! check_interface_up "ppp0" ; do
	log_message "Waiting for ppp0 to be up, $attempt out of $max_attempts"
	
	# Wait a bit before checking again
	sleep 5

	# Increment the attempt counter
	((attempt++))
done

# Desired MTU value
desired_mtu=1500

# Function to get the MTU value of ppp0 interface
get_mtu() {
    local mtu
    mtu=$(ip link show ppp0 | grep -oP 'mtu \K\d+')
    #log_message "get_mtu found mtu $mtu"
    echo $mtu
}

# Function to validate if a value is an integer
is_integer() {
    [[ $1 =~ ^-?[0-9]+$ ]]
}

# Maximum number of attempts to get a valid MTU value
max_attempts=10
attempt=1

# Initial attempt to get MTU
current_mtu=$(get_mtu)

# Retry loop if MTU is not an integer
while ! is_integer "$current_mtu" && [ "$attempt" -le "$max_attempts" ]; do
    log_message "Attempt $attempt: Failed to get a valid MTU value for ppp0 (found:$current_mtu) . Retrying in 5 seconds..."
    
    # Wait for 5 seconds before retrying
    sleep 5
    
    # Increment attempt counter and retry getting MTU
    ((attempt++))
    current_mtu=$(get_mtu)
done

# Check if a valid MTU was obtained
if is_integer "$current_mtu"; then
    log_message "Successfully obtained MTU for ppp0: $current_mtu"
else
    log_message "Failed to obtain a valid MTU value for ppp0 after $max_attempts attempts."
    exit 1
fi


# Check if the current MTU matches the desired MTU
if [ "$current_mtu" -eq "$desired_mtu" ]; then
    log_message "MTU for ppp0 is $desired_mtu, nothing to do so exiting..."
    exit 0 
fi


# set mtu and mru to 1500 in /etc/ppp/peers/ppp0
log_message set MTU and MRU to 1500 in /etc/ppp/peers/ppp0
sed -i 's/ 1492/ 1500/g' /etc/ppp/peers/ppp0

log_message set eth4 mtu to 1512
ip link set dev eth4 mtu 1512 
log_message set eth4.6 mtu to 1508
ip link set dev eth4.6 mtu 1508 

reset_interface "eth4.6"
reset_interface "eth4"

# Function to check IPv4 connectivity
check_ipv4_connectivity() {
    # Ping a known reliable IPv4 address
    if ping -c 4 8.8.8.8 > /dev/null 2>&1; then
        echo "IPv4 connectivity: OK"
        return 0 # Success exit code
    else
        echo "IPv4 connectivity: Failed"
        return 1 # Failure exit code
    fi
}

log_message "sleeping for 5 seconds..."
sleep 5
log_message "killing pppd..."
killall pppd
log_message "sleeping for 30 seconds..."
sleep 30

while ! check_ipv4_connectivity ; do
   log_message "no IPv4 connectivity, killing pppd..."
   killall pppd
   log_message "sleeping for 30 seconds..."   
   sleep 30
done

log_message "All should be good now!"
log_message "Finished."
