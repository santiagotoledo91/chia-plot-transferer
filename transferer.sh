#!/bin/bash

# Plot
PLOT_NAME="$1"
PART_SIZE=10G

BASE_PLOTS_PATH="<CHANGEME>"
BASE_TRANSFERS_PATH="<CHANGEME>"

PLOT_TRANSFER_FOLDER_PATH="$BASE_TRANSFERS_PATH/$PLOT_NAME"
PLOT_PATH="$BASE_PLOTS_PATH/$PLOT_NAME"

# Remote
REMOTE_USER="<CHANGEME>"
REMOTE_HOST="<CHANGEME>"
REMOTE_DISK="<CHANGEME>"
REMOTE_FOLDER=$PLOT_NAME

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Starting plot transfer: $PLOT_NAME"

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Creating plot transfer folder"
mkdir -p "$PLOT_TRANSFER_FOLDER_PATH"

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Moving plot to transfer forlder"
mv "$PLOT_PATH" "$PLOT_TRANSFER_FOLDER_PATH"
cd "$PLOT_TRANSFER_FOLDER_PATH"

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Splitting plot file"
rar a -v"$PART_SIZE" -m0 -o+ "$PLOT_NAME.rar" "$PLOT_NAME"

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Deleting original plot - DISABLED"
rm $PLOT_PATH

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Creating transfer folder on remote"
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_DISK/$REMOTE_FOLDER && exit"

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Transfering plot parts"
find . -name '*.part*.rar' -type f -print | parallel --retries 3 --delay 1 "scp {} "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DISK/$REMOTE_FOLDER"/{} && rm {}"

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Joining parts on remote"
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DISK/$REMOTE_FOLDER && rar x -o+ $PLOT_NAME.part01.rar && rm $PLOT_NAME.part*.rar && exit" 

echo $(date +"%Y-%m-%d_%H:%M_%S") "- Transfer complete"

rm -rf $PLOT_TRANSFER_FOLDER_PATH

exit 0
