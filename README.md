# Memory Usage Monitoring Script

This Bash script monitors the memory usage of processes containing a specific search term and saves the data to a log file. It also calculates the average memory usage of all processes and saves that to the log file as well. The script runs continuously until stopped and can be used to monitor the memory usage of specific processes over time.

## Requirements

This script requires a Linux-based operating system with Bash installed. It also requires the following commands to be available: `pgrep`, `ps`, `pmap`, `awk`, `sed`, `date`, and `sleep`.

## Usage

To use the script, download the `memory-usage.sh` file and make it executable using the command `chmod +x memory-usage.sh`. Modify the variables at the beginning of the script to set the search term and log file path.

### Running as a service

To run the script as a service on a Linux-based system, follow these steps:

1. Create a new systemd service file by running the command `sudo nano /etc/systemd/system/memory-usage.service`.
2. Paste the following code into the file:

```
[Unit]
Description=Memory Usage Monitoring Script
After=network.target

[Service]
User=root
Group=root
Type=simple
WorkingDirectory=/path/to/script/directory
ExecStart=/path/to/memory-usage.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

Make sure to replace `/path/to/script/directory` with the path to the directory where the `memory-usage.sh` script is located, and replace `/path/to/memory-usage.sh` with the full path to the `memory-usage.sh` script.

3. Save the file by pressing `Ctrl+X`, then `Y`, then `Enter`.
4. Reload the systemd daemon by running the command `sudo systemctl daemon-reload`.
5. Start the service by running the command `sudo systemctl start memory-usage`.
6. Verify that the service is running by running the command `sudo systemctl status memory-usage`. If the service is running correctly, the output should say `Active: active (running)`.

The script will now run as a service and continue monitoring memory usage even if the terminal window is closed. To stop the service, run the command `sudo systemctl stop memory-usage`. To start the service automatically at boot, run the command `sudo systemctl enable memory-usage`.

### Running as a background process

To run the script as a background process, simply run the command `./memory-usage.sh &` from the command line. The script will run in the background and continue monitoring memory usage even if the terminal window is closed.

## Testing

To test the script, download the `memory-usage.bats` file and run the command `bats memory-usage.bats`. The tests will verify that the script is working correctly and saving data to the log file.

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

This script was created by [MartinRep](https://github.com/[martinrep]).
