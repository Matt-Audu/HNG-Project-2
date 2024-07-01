#!/bin/bash

# Check if a file name was provided as an argument

EMPLOYEE_FILE="$1"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure log and password files exist
touch "$LOG_FILE"
mkdir -p "$(dirname "$PASSWORD_FILE")"
touch "$PASSWORD_FILE"

# Set password file permissions
chmod 600 "$PASSWORD_FILE"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if the employee file exists
if [[ ! -f "$EMPLOYEE_FILE" ]]; then
    log "Employee file $EMPLOYEE_FILE not found."
    exit 1
fi

if [ -z "$EMPLOYEE_FILE" ]; then
    log "No user file provided. Exiting."
    exit 1
fi

# Process each line in the employee file
while IFS=';' read -r username groups; do
    if id "$username" &>/dev/null; then
        log "User $username already exists. Skipping."
        continue
    fi

    # Create user with home directory
    useradd -m -s /bin/bash "$username"
    if [[ $? -ne 0 ]]; then
        log "Failed to create user $username."
        continue
    fi

    log "User $username created."

    # Set up primary group
    if [[ ! $(getent group "$username") ]]; then
        groupadd "$username"
        log "Group $username created."
    fi

    usermod -g "$username" "$username"
    log "User $username assigned to group $username."

    # Set up additional groups
    IFS=',' read -ra group_array <<< "$groups"
    for group in "${group_array[@]}"; do
        if [[ ! $(getent group "$group") ]]; then
            groupadd "$group"
            log "Group $group created."
        fi
        usermod -aG "$group" "$username"
        log "User $username added to group $group."
    done

    # Generate random password
    password=$(openssl rand -base64 12)
    echo "$username:$password" | chpasswd
    if [[ $? -ne 0 ]]; then
        log "Failed to set password for user $username."
        continue
    fi
    log "Password set for user $username."

    # Store password securely
    echo "$username,$password" >> "$PASSWORD_FILE"
    log "Password stored securely for user $username."

    # Set home directory permissions
    chmod 700 "/home/$username"
    chown "$username:$username" "/home/$username"
    log "Home directory permissions set for user $username."

done < "$EMPLOYEE_FILE"

log "User creation process completed."

exit 0





