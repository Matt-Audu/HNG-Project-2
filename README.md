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

