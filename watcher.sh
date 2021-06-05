#!/bin/sh

LOGS_FOLDER_PATH="<CHANGEME>"
PLOTS_FOLDER_PATH="<CHANGEME>"
TRANSFER_SCRIPT_PATH="<CHANGEME>"

echo "Chia plot transferer - Watcher started"

while NEW_PLOT=$(inotifywait -q -e close_write -e moved_to "$PLOTS_FOLDER_PATH" --format %f .); do

	echo "\n\n"
	echo " New plot!"
	bash "$TRANSFER_SCRIPT_PATH" "$NEW_PLOT" > "$LOGS_FOLDER_PATH/$NEW_PLOT.log" 2>&1 &
	echo " Transfer started for $NEW_PLOT" 
	echo " Log at: $LOGS_FOLDER_PATH/$NEW_PLOT.log"
	echo "\n\n"
done

