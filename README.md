# Automating User Management in linux

### Overview

This script automates the process of creating user accounts on a Linux system. It reads a specified file containing user information, creates user accounts with home directories, sets up personal and additional groups, generates random passwords, and logs the process.

### Prerequisites

- The script must be run with root privileges to create user accounts and modify system files.
- The employee file must be provided as an argument when running the script.
- The employee file must be present in the same directory of the script.
- Use a linux server (Ubuntu machine).

### Script Usage

```
./create_users.sh <employee.txt>
```

### Employee File Format

The employee file should be a text file where each line represents a user and their groups. The format for each line is:

```
username;group1,group2,group3
```

- `username`: The name of the user to be created.
- `group1,group2,group3`: A comma-separated list of additional groups the user should be added to.

### Script Details

#### 1. Initialization

```
EMPLOYEE_FILE="$1"
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"
```

- `EMPLOYEE_FILE`: The first argument passed to the script, which should be the path to the employee file.
- `LOG_FILE`: The path to the log file where script activity will be recorded.
- `PASSWORD_FILE`: The path to the file where user passwords will be securely stored.

#### 2. File Setup

```
touch "$LOG_FILE"
mkdir -p "$(dirname "$PASSWORD_FILE")"
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"
```

- Ensures the log and password files exist.
- Sets permissions on the password file to be readable and writable only by the owner.

#### 3. Logging Function

```
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}
```

- A function to log messages with timestamps to both the console and the log file.

#### 4. File Existence Checks

```
if [[ ! -f "$EMPLOYEE_FILE" ]]; then
    log "Employee file $EMPLOYEE_FILE not found."
    exit 1
fi

if [ -z "$EMPLOYEE_FILE" ]; then
    log "No user file provided. Exiting."
    exit 1
fi
```

- Checks if the employee file exists and exits if it does not.

#### 5. Processsing User Entries

```
while IFS=';' read -r username groups; do
    ...
done < "$EMPLOYEE_FILE"
```

- Reads each line in the employee file, splitting the username and groups.

#### 6. User Creation and Setup

```
if id "$username" &>/dev/null; then
    log "User $username already exists. Skipping."
    continue
fi

useradd -m -s /bin/bash "$username"
```

- Checks if the user already exists and skips if they do.
- Creates the user with a home directory and Bash shell.

#### 7. Primary Group Setup

```
if [[ ! $(getent group "$username") ]]; then
    groupadd "$username"
    log "Group $username created."
fi

usermod -g "$username" "$username"
log "User $username assigned to group $username."
```

- Creates a personal group for the user with the same username if it doesn't already exist and assigns the user to this group.

#### 8. Additional Groups

```
IFS=',' read -ra group_array <<< "$groups"
for group in "${group_array[@]}"; do
    ...
done
```

- Adds the user to any additional groups specified in the employee.txt file.

#### 9. Password Generation and Assignment

```
password=$(openssl rand -base64 12)
echo "$username:$password" | chpasswd
```

- Generates a random password for the user and sets it.

#### 10. Securely Store Passwords

```
echo "$username,$password" >> "$PASSWORD_FILE"
log "Password stored securely for user $username."
```

- Stores the password in "/var/secure/user_passwords.txt"

#### 11. Setting Home Directory Permissions

```
chmod 700 "/home/$username"
chown "$username:$username" "/home/$username"
log "Home directory permissions set for user $username."
```

- Sets appropriate permissions on the user's home directory.

#### 12. Completion Log

```
log "User creation process completed."
```

- Logs the completion of the user creation process.

### Logging and Security

- Log File: `/var/log/user_management.log` records the script's activity.
- Password File: `/var/secure/user_passwords.txt` stores the generated passwords securely, with permissions set to allow access only by the owner.

### Conclusion

This script streamlines the user creation process on a Linux system by automating the setup of user accounts, groups, and passwords, while ensuring security and proper logging.







