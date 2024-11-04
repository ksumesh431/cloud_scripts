#!/bin/bash


# Create a named pipe (FIFO)
pipe=/tmp/mypipe
mkfifo "$pipe"

# Run the first command in the background and redirect its output to the named pipe
node main.js > "$pipe" &

# Read from the named pipe, which will block until the first command completes
read < "$pipe"

# Once the first command completes, remove the named pipe 
rm "$pipe"

# Execute the second command
explorer.exe file.xlsx

