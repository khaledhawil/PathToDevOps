# 227-[LX]-Lab - Linux Command Line


##  Summary of Linux Commands in the Exercise
## 1. Basic System Information Commands
- `whoami` → Displays the current logged-in user.
- `hostname -s` → Shows the **short** hostname of the system.
- `uptime -p` → Displays system uptime in a **human-readable** format.

## 2. User and Session Information
- `who -H -a` → Shows detailed information about **logged-in users**, including session details and process IDs.

## 3. Time and Date Commands
- `TZ=America/New_York date` → Shows the current date and time in the **New York timezone**.
- `TZ=America/Los_Angeles date` → Shows the current date and time in the **Los Angeles timezone**.
- `cal -j` → Displays the **Julian calendar**, where days continue counting without resetting at the start of a new month.
- `cal -s` → Shows the **calendar starting from Sunday**.
- `cal -m` → Shows the **calendar starting from Monday**.
- `man cal` → Displays the manual page for the `cal` command, listing all available options.

## 4. User ID and Group Information
- `id ec2-user` → Displays the **user ID (UID), group ID (GID), and groups** the user belongs to.

## 5. Command History and Reuse
- `history` → Lists all previously executed commands.
- `CTRL + R` → Starts a **reverse search** in the command history.
- `!!` → Runs the **last executed command again**.



 ***These commands help in system monitoring, troubleshooting, workflow efficiency, and time management in Linux environments***