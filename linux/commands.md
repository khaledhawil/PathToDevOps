```bash
aw$ readlink -f Notes.txt* # -->  print absolute path of file 

shuf -i 9999999-99999999 -n 2 # ---> create a random 8 digit 
sudo tail -f /var/log/auth.log  # View the most recent logs:
sudo timedatectl set-ntp 0 # stop automatically time 
sudo timedatectl set-ntp 1 # start automatically time 
sudo timedatectl set-time 18:15 # to change the time to what U want :
dpkg-query -W --showformat='${Package}\t${Installed-size}\n' | awk '{printf "%-30s %.2f MB (%.2f GB)\n", $1, $2/1024, $2/1048576}' | sort -k2 -n

s s3api create-bucket --bucket s3-bash-hawil --create-bucket-configuration LocationConstraint=eu-north-1

too long

```