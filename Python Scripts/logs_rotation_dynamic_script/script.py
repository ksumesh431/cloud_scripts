#!/usr/bin/python

from datetime import datetime, timedelta
import os
import subprocess
import shutil
import re
import requests

logs_archival_root_path = "processed_logs/"
tomcat_log_path = "production_logs/"
tomcat_log_path_archive = "production_logs/archive"
date_format = "%d_%m_%Y"
current_date = datetime.now()
current_date__string = datetime.now().strftime(date_format)
date_of_logs = datetime.strptime(current_date__string, date_format) - timedelta(
    days=1
)  # date for which the logs will be processed
date_of_logs__string = (current_date - timedelta(days=1)).strftime(date_format)
starting_day_of_log_archival = (
    "Wednesday"  # Case sensitive format like "Monday", "Tuesday"
)
slack_hook_url = (
    "https://hooks.slack.com/services/HST1R7/DSAJYGHD5/sdffHJHJSD6712"
)
hostname = "TOMCAT-GW"


def send_slack_alert(error, color="#FF0000"):
    now = datetime.now().strftime("%d/%b/%Y %H:%M:%S")

    message = (
        f"*filebeat s3 archive failed*\n"
        f"On machine *{hostname}*\n"
        f"*Detected at: {now}*\n"
        f"Error: {error}"
    )

    # print(f"Message: {message}")
    data = {"attachments": [{"text": f"*{message}*", "color": color}]}
    response = requests.post(slack_hook_url, json=data)
    print("alert sent:", response.text)


def last_occurrence_of_day(required_day, date_obj):

    days_mapping = {
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4,
        "Saturday": 5,
        "Sunday": 6,
    }

    # integer value of the required day
    required_day_index = days_mapping[required_day]
    diff_days = (date_obj.weekday() - required_day_index) % 7
    last_occurrence_date = date_obj - timedelta(days=diff_days)

    return last_occurrence_date


def get_date_range_directory_path(start_date, end_date):
    try:
        # Format dates
        start_date_str = start_date.strftime(date_format)
        end_date_str = end_date.strftime(date_format)

        directory_name = f"{start_date_str}_to_{end_date_str}"
        directory_path = os.path.join(logs_archival_root_path, directory_name)

        return directory_path
    except AttributeError:
        print(
            "Error: get_date_range_directory_path() - Invalid date format. Please provide date in the format datetime.datetime."
        )
        return ""


def get_creation_date_of_file(file_path):
    # Run the Bash commands and capture the output
    date_from_ls = (
        subprocess.check_output(
            f"ls -l {file_path} | awk '{{print $6, $7}}'", shell=True
        )
        .decode()
        .strip()
    )

    year_from_stat = (
        subprocess.check_output(
            f"stat -c %y {file_path} | awk '{{print substr($1, 1, 4)}}'", shell=True
        )
        .decode()
        .strip()
    )

    # Combine date and year
    full_date = f"{date_from_ls} {year_from_stat}"

    # Convert full_date to datetime object
    datetime_obj = datetime.strptime(full_date, "%b %d %Y")

    formatted_date = datetime_obj.strftime(date_format)

    return formatted_date


def datewise_search_and_push(path_to_search, path_to_push, date_to_search):
    if (
        os.path.exists(path_to_search)
        and os.path.isdir(path_to_search)
        and os.path.exists(path_to_push)
        and os.path.isdir(path_to_push)
    ):

        matching_files = []
        files = os.listdir(path_to_search)
        for file in files:
            file_path = os.path.join(path_to_search, file)
            if os.path.isfile(file_path):

                try:
                    file_creation_time = get_creation_date_of_file(file_path)
                except Exception as e:
                    send_slack_alert(str(e))
                    exit(
                        f"Failed to get creation date of file {file_path}. Error: {str(e)}"
                    )

                if (
                    file_creation_time == date_to_search
                    and ("ecs-tomcat-" in file_path)
                    and file_path.endswith(".server.log")
                ):

                    matching_files.append(file_path)

        for file in matching_files:
            print(f"Moving file: {file} to {path_to_push}\n")
            shutil.move(file, path_to_push)

    else:
        exit("Error: path_to_search or path_to_push does not exist")


def datewise_grep_log_archives_and_push(
    path_to_search, path_to_push, date_string_to_grep
):
    if (
        os.path.exists(path_to_search)
        and os.path.isdir(path_to_search)
        and os.path.exists(path_to_push)
        and os.path.isdir(path_to_push)
    ):
        matching_files = []
        files = os.listdir(path_to_search)
        for file in files:
            # print(f"Checking file: {file}")
            file_path = os.path.join(path_to_search, file)
            if os.path.isfile(file_path):

                if ("ecs-tomcat-" in file_path) and re.search(
                    r"\.server\.log\." + date_string_to_grep + r"_[0-9]{2}\.gz$",
                    file_path,
                ):
                    matching_files.append(file_path)

        for file in matching_files:
            print(f"Moving file: {file} to {path_to_push}\n")
            shutil.move(file, path_to_push)

    else:
        exit("Error: path_to_search or path_to_push does not exist")


def cleanup_logs_older_than_date(date_obj, path_to_check, path_to_store):

    files_to_move = os.listdir(path_to_check)

    for file_name in files_to_move:
        file_path = os.path.join(path_to_check, file_name)
        if os.path.isfile(file_path):

            creation_date = get_creation_date_of_file(file_path)

            # Convert the creation date to a datetime object
            creation_datetime = datetime.strptime(creation_date, date_format)

            # For regular logs
            if (
                creation_datetime < date_obj
                and ("ecs-tomcat-" in file_path)
                and file_path.endswith(".server.log")
            ):
                destination_path = os.path.join(path_to_store, file_name)
                print(f"Moving extra log file: {file_path} to {destination_path}\n")
                shutil.move(file_path, destination_path)

            # For logs inside archive folder
            if (
                creation_datetime < date_obj
                and ("ecs-tomcat-" in file_path)
                and file_path.endswith(".gz")
            ):
                destination_path = os.path.join(path_to_store, file_name)
                print(f"Moving extra log file: {file_path} to {destination_path}\n")
                shutil.move(file_path, destination_path)


def compress_directory(path_to_archive, archive_destination):
    """Compresses a directory into a tar.gz file using the tar command.

    Args:
        path_to_archive (str): The path to the directory to compress.
        archive_name (str): The desired name for the archive file (without extension).
        archive_destination (str): The path to the directory where the archive should be created.
    """
    # Get the base directory name from the path_to_archive
    base_dir = os.path.basename(path_to_archive)

    # Construct the full path for the archive file
    archive_path = os.path.join(archive_destination, f"{base_dir}.tar.gz")

    # Create the tar command
    tar_command = [
        "tar",
        "-czf",
        archive_path,
        "-C",
        os.path.dirname(path_to_archive),
        base_dir,
    ]

    try:
        # Run the tar command
        subprocess.run(tar_command, check=True)
        print(f"Directory '{path_to_archive}' compressed to '{archive_path}'\n")
    except subprocess.CalledProcessError as e:
        print(f"Error compressing directory: {e}")


def main():
    """
    Main function of the script
    """

    start_date = ""
    end_date = ""

    if current_date.strftime("%A") == starting_day_of_log_archival:
        start_date = current_date
        end_date = datetime.strptime(current_date__string, date_format) + timedelta(
            days=6
        )
    else:
        start_date = last_occurrence_of_day(starting_day_of_log_archival, current_date)
        end_date = start_date + timedelta(days=6)

    previous_start_date = start_date - timedelta(days=7)
    previous_end_date = end_date - timedelta(days=7)

    # print(f"\nstart date: {start_date}")
    # print(f"end date: {end_date}")
    # print(f"previous start date: {previous_start_date}")
    # print(f"previous end date: {previous_end_date}\n\n")




    ####################################################################################################
    ######################## main "current_date_to_end_date" directory creation ########################
    print(
        f"########################### Generating main_directory_path from {start_date.strftime(date_format)} to {end_date.strftime(date_format)} ###########################\n"
    )
    main_directory_path = get_date_range_directory_path(start_date, end_date)
    print(f"main_directory_path is ====> '{main_directory_path}' \n")
    print(f"Creating directory at '{main_directory_path}' if it doesn't exist...\n")

    if main_directory_path != "" and main_directory_path != logs_archival_root_path:
        if not os.path.exists(main_directory_path):
            os.makedirs(main_directory_path)
    else:
        exit("Error: main_directory_path does not exist")
    ######################## main "current_date_to_end_date" directory creation ########################
    ####################################################################################################




    # Previous main_directory_path
    previous_main_directory_path = get_date_range_directory_path(
        previous_start_date, previous_end_date
    )
    print(f"previous_main_directory_path is ====> '{previous_main_directory_path}' \n")




    ######################################################################################################
    ################################ Datewise logs directory creation inside ############################
    logs_directory_path = ""
    if main_directory_path != "" and main_directory_path != logs_archival_root_path:
        print(
            f"\n\n####################################### Generating logs_directory_path #######################################\n"
        )

        if date_of_logs == previous_end_date:
            logs_directory_path = os.path.join(
                previous_main_directory_path, date_of_logs__string
            )
        else:
            logs_directory_path = os.path.join(
                main_directory_path, date_of_logs__string
            )

        print(
            f"Creating directory at logs_directory_path ====> '{logs_directory_path}' if it doesn't exist...\n"
        )

        if not os.path.exists(logs_directory_path):
            os.makedirs(logs_directory_path)

    else:
        exit("Error: main_directory_path does not exist")

    # Error handling if the directory doesnt gets created for some reason
    if not os.path.exists(logs_directory_path):
        exit("Error creating logs_directory_path directory")
    ################################ Datewise logs directory creation inside ############################
    ######################################################################################################




    # PUSH LOGS AND LOGS.GZ TO logs_directory_path
    if logs_directory_path:
        try:
            ########################################################################################################
            ############################## Search and push log files from tomcat log path ##########################
            ########################################################################################################
            print(
                f"Searching logs created on {date_of_logs__string} in the '{tomcat_log_path}' directory to push...\n"
            )

            datewise_search_and_push(
                tomcat_log_path, logs_directory_path, date_of_logs__string
            )

            ########################################################################################################
            ################# Search and push log files from tomcat log path (archive directory) ###################
            ########################################################################################################
            print(
                f"Searching logs created on {date_of_logs__string} in the '{tomcat_log_path_archive}' directory to push...\n"
            )
            datewise_grep_log_archives_and_push(
                tomcat_log_path_archive,
                logs_directory_path,
                date_of_logs.strftime("%Y-%m-%d"),
            )
        except Exception as e:
            send_slack_alert(str(e))
            exit(f"Error pushing logs: {str(e)}")
    else:
        exit("Error generating logs directory path")




    ########################################################################################################
    ########################################################################################################
    # If current day is the same as starting day of log archival
    # Check and move extra logs to extra_logs directory
    # Create zip and send logs to s3
    if current_date.strftime("%A") == starting_day_of_log_archival:
        try:

            extra_logs_path = os.path.join(previous_main_directory_path, "extra_logs")
            if not os.path.exists(extra_logs_path):
                os.makedirs(extra_logs_path)

            print(
                f"Cleaning up extra logs older than {date_of_logs} and pushing in '{extra_logs_path}' directory...\n"
            )
            cleanup_logs_older_than_date(date_of_logs, tomcat_log_path, extra_logs_path)
            cleanup_logs_older_than_date(
                date_of_logs, tomcat_log_path_archive, extra_logs_path
            )
        except Exception as e:
            send_slack_alert(str(e))
            exit(f"Error cleaning up extra logs: {str(e)}")

        try:
            print(
                f"\n\n######################## Compressing '{previous_main_directory_path}' directory and storing at {logs_archival_root_path} ########################\n"
            )
            compress_directory(previous_main_directory_path, logs_archival_root_path)
        except Exception as e:
            send_slack_alert(str(e))
            exit(f"Error archiving logs: {str(e)}")
    ########################################################################################################
    ########################################################################################################


if __name__ == "__main__":
    main()
