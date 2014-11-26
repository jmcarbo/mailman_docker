#!/usr/bin/env bash

# Backup mailman data and send backup to google drive.
# This script should be run periodically.

# Example for a line in a crontab:
# Run "sudo crontab -e" and add the following line:
# Backup mailman daily (And write to log)
# * * * * * /full/path/to/backup_mailman.sh >> /var/log/backup_mailman.log 2>&1


# Abort on failure:
set -e

# Full path of gdrive_docker dir:
GDRIVE_DOCKER_PATH="/home/real/projects/gdrive_docker"
# Full path of mailman_docker dir:
MAILMAN_DOCKER_PATH="/home/real/projects/mailman_docker"

# Create a temporary directory:
temp_dir=`mktemp -d`

# Stop mailman docker container:
cd ${MAILMAN_DOCKER_PATH}
./stop_server.sh

# Filename is generated by time:
now=$(date +%Y_%m_%d_%H_%M_%S)
back_file="${temp_dir}/backup_${now}.tar"

echo "Backup file name: $back_file"
# Create a backup file for mailman's data:
./backup_data.sh ${back_file}

# Start mailman docker container:
./start_server.sh

# Upload to google drive:
cd ${GDRIVE_DOCKER_PATH}
./store_file.sh ${back_file} /flayer_mm_backup/

# Remove temp directory:
rm -rf ${temp_dir}

# Unset abort on failure:
set +e