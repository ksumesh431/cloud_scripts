import os, subprocess, re, requests, shutil
from datetime import datetime, timedelta

hostname = subprocess.check_output(["hostname"]).decode().strip()

# result path where final logs directories will be created
processed_logs_path = "processed_logs/"

# container logs path from where logs will be copied
container_logs_path = "logs/sample_logs/"
container_logs_path_archive = os.path.join(container_logs_path, "archive/")

date_format = "%d_%m_%Y"
current_date = datetime.now()
current_date__string = current_date.strftime(date_format)

# one day old date for which the logs will be processed
date_of_logs = current_date - timedelta(days=1)
date_of_logs__string = date_of_logs.strftime(date_format)

# The day from where start and end date will be calculated
starting_day_of_log_archival = (
    "Monday"  # Case sensitive format like "Monday", "Tuesday"
)

# Files starting with "ecs",
# with one of the patterns and
# ending with "".server.log" will be matched (ending with ".server.log.{provided_date_string}.gz" in case of archived logs)
patterns_to_match = [
    "-tomcat-",
    "-tomcat_external-",
    "-batch_report-",
    "-batch-",
    "-batch_notification-",
]

slack_hook_url = ""


# Uncomment slack alert code
def send_slack_alert(error, color="#FF0000"):
    now = datetime.now().strftime("%d/%b/%Y %H:%M:%S")

    message = (
        f"*filebeat s3 archive failed*\n"
        f"On machine *{hostname}*\n"
        f"*Detected at: {now}*\n"
        f"Error: {error}"
    )

    print(f"Message: {message}")
    data = {"attachments": [{"text": f"*{message}*", "color": color}]}
    # response = requests.post(slack_hook_url, json=data)
    # print("alert sent:", response.text)


def last_occurrence_of_day(required_day, date_obj):
    """
    Calculate the date of the last occurrence of the given day.

    This function takes a string representing a day of the week and a datetime
    object, and returns the date of the last occurrence of that day.

    For example, if the given day is "Monday" and the given datetime is a
    Wednesday, the function will return the date of the previous Monday.

    :param required_day: The day of the week to find the last occurrence of.
                         Must be a string, case sensitive (e.g. "Monday").
    :param date_obj: The datetime object to find the last occurrence from.
    :return: The date of the last occurrence of the given day.
    """
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
        directory_path = os.path.join(processed_logs_path, directory_name)

        return directory_path
    except AttributeError:
        print(
            "Error: get_date_range_directory_path() - Invalid date format. Please provide date in the format datetime.datetime."
        )
        return ""


def get_creation_date_of_file(file_path):
    """Get creation date of a file in a specific format.

    Args:
        file_path (str): Path to the file.

    Returns:
        str: Creation date of the file in the format "%d_%m_%Y".
    """

    year_from_stat = subprocess.check_output(
        f"stat -c %y {file_path}", shell=True, universal_newlines=True
    ).strip()[:4]

    date_from_ls = subprocess.check_output(
        f"ls -l {file_path}", shell=True, universal_newlines=True
    ).split()[5:7]

    full_date = f"{' '.join(date_from_ls)} {year_from_stat}"

    return datetime.strptime(full_date, "%b %d %Y").strftime(date_format)


def log_files_pattern_match(file_path):
    # Construct the regex pattern dynamically
    # Ensure the path contains `ecs` as a whole word, one of the patterns, and ends with `.server.log`
    regex_pattern = (
        r"^.*\becs\b.*("
        + "|".join(re.escape(pattern) for pattern in patterns_to_match)
        + r").*\.server\.log$"
    )

    # Use re.search to check if the pattern matches the file_path
    if re.search(regex_pattern, file_path):
        return True
    else:
        return False


def archived_log_files_pattern_match(file_path, date_string):
    """
    Matches file paths that:
    - Start with `ecs`
    - Contain one of the provided patterns
    - Contain `.server.log`
    - Contain the exact date string provided
    - End with `.gz`
    """
    # Construct the regex pattern dynamically
    regex_pattern = (
        r"^.*\/ecs-("
        + "|".join(
            re.escape(pattern.lstrip("-").rstrip("-")) for pattern in patterns_to_match
        )
        + r")-\d+\.server\.log\."
        + re.escape(date_string)
        + r"_\d+\.gz$"
    )

    # Use re.search to check if the pattern matches the file_path
    if re.search(regex_pattern, file_path):
        return True
    else:
        return False


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
            if log_files_pattern_match(file_path) and os.path.isfile(file_path):

                try:
                    file_creation_time = get_creation_date_of_file(file_path)
                except Exception as e:

                    send_slack_alert(str(e))
                    print(
                        f"Failed to get creation date of file {file_path}. Error: {str(e)}"
                    )
                    exit(
                        f"Failed to get creation date of file {file_path}. Error: {str(e)}"
                    )

                if file_creation_time == date_to_search:
                    matching_files.append(file_path)
            else:
                continue
        if not matching_files:
            print("\nNo archived logs matched for today\n")

        for file in matching_files:
            print(f"Moving file: {file} to {path_to_push}\n")
            try:
                shutil.move(file, path_to_push)
            except Exception as e:
                send_slack_alert(str(e))
                print(f"Failed to move file {file}. Error: {str(e)}")
                exit(f"Failed to move file {file}. Error: {str(e)}")

    else:
        send_slack_alert("Error: path_to_search or path_to_push does not exist")
        print("Error: path_to_search or path_to_push does not exist")
        exit("Error: path_to_search or path_to_push does not exist")


def datewise_search_and_push_archive(path_to_search, path_to_push, date_to_search):
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
            if archived_log_files_pattern_match(
                file_path, date_to_search
            ) and os.path.isfile(file_path):
                matching_files.append(file_path)
            else:
                continue

        if not matching_files:
            print("\nNo archived logs matched for today\n")

        for file in matching_files:
            print(f"Moving file: {file} to {path_to_push}\n")
            try:
                shutil.move(file, path_to_push)
            except Exception as e:
                send_slack_alert(str(e))
                print(f"Failed to move file {file}. Error: {str(e)}")
                exit(f"Failed to move file {file}. Error: {str(e)}")

    else:
        send_slack_alert("Error: path_to_search or path_to_push does not exist")
        print("Error: path_to_search or path_to_push does not exist")
        exit("Error: path_to_search or path_to_push does not exist")


def cleanup_logs_older_than_date(date_obj, path_to_check, path_to_store):

    files_to_move = os.listdir(path_to_check)

    regex_pattern_regular_logs = (
        r"^.*\becs\b.*("
        + "|".join(re.escape(pattern) for pattern in patterns_to_match)
        + r").*\.server\.log$"
    )
    regex_pattern_archive_logs = (
        r"^.*\becs\b.*("
        + "|".join(re.escape(pattern) for pattern in patterns_to_match)
        + r").*\.server\.log\.\d{4}-\d{2}-\d{2}_\d+\.gz$"
    )

    for file_name in files_to_move:
        file_path = os.path.join(path_to_check, file_name)

        if os.path.isfile(file_path):
            creation_date = get_creation_date_of_file(file_path)
            creation_date_object = datetime.strptime(
                creation_date, date_format
            )  # Convert the creation date to a datetime object

            if creation_date_object < date_obj:
                # for regular logs
                if re.search(regex_pattern_regular_logs, file_path):
                    destination_path = os.path.join(path_to_store, file_name)
                    print(f"Moving extra log file: {file_path} to {destination_path}\n")
                    shutil.move(file_path, destination_path)

                # for logs inside archive folder
                if re.search(regex_pattern_archive_logs, file_path):
                    destination_path = os.path.join(path_to_store, file_name)
                    print(
                        f"Moving extra log file (archived): {file_path} to {destination_path}\n"
                    )
                    shutil.move(file_path, destination_path)
            else:
                continue
        else:
            continue


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
        send_slack_alert(f"Error compressing directory: {e}")
        print(f"Error compressing directory: {e}")
        exit(f"Error compressing directory: {e}")


def main():
    try:
        start_date = ""
        end_date = ""

        if current_date.strftime("%A") == starting_day_of_log_archival:
            start_date = current_date
            end_date = current_date + timedelta(days=6)
        else:
            start_date = last_occurrence_of_day(
                starting_day_of_log_archival, current_date
            )
            end_date = start_date + timedelta(days=6)

        # Previous start and end date
        previous_start_date = start_date - timedelta(days=7)
        previous_end_date = end_date - timedelta(days=7)

        # Previous main_directory_path
        previous_main_directory_path = get_date_range_directory_path(
            previous_start_date, previous_end_date
        )
        print(
            f"\nPrevious_main_directory_path is ==> '{previous_main_directory_path}' \n\n"
        )  # like 'processed_logs/30_12_2024_to_05_01_2025'

        #
        #
        #
        #

        ####################################################################################################################
        ####################################################################################################################
        ######################## main "current_date_to_end_date" directory creation ########################################
        ####################################################################################################################
        print(
            f"########################### Generating main_directory_path from {start_date.strftime(date_format)} to {end_date.strftime(date_format)} ###########################\n"
        )
        main_directory_path = get_date_range_directory_path(start_date, end_date)
        print(
            f"main_directory_path is ==> '{main_directory_path}' \n"
        )  # like 'processed_logs/06_01_2025_to_12_01_2025'
        print(f"Creating directory at '{main_directory_path}' if it doesn't exist...\n")
        if main_directory_path != "" and main_directory_path != processed_logs_path:
            os.makedirs(main_directory_path, exist_ok=True)
        else:
            send_slack_alert("main_directory_path does not exist")
            print("main_directory_path does not exist")
            exit("main_directory_path does not exist")
        ####################################################################################################################
        ######################## main "current_date_to_end_date" directory creation ########################################
        ####################################################################################################################
        ####################################################################################################################

        #
        #
        #
        #

        ####################################################################################################################
        ####################################################################################################################
        ######################## logs date directory creation inside the main_directory_path ###############################
        ####################################################################################################################
        logs_directory_path = ""
        if main_directory_path != "" and main_directory_path != processed_logs_path:
            print(
                f"\n\n\n####################################### Generating yesterday's logs_directory_path #######################################\n"
            )
            # In case yesterday was last date of the previous date range, then use previous_main_directory_path
            if date_of_logs == previous_end_date:
                logs_directory_path = os.path.join(
                    previous_main_directory_path, date_of_logs__string
                )
            else:
                logs_directory_path = os.path.join(
                    main_directory_path, date_of_logs__string
                )
            print(
                f"Creating directory at logs_directory_path ==> '{logs_directory_path}' if it doesn't exist...\n"
            )
            if not os.path.exists(logs_directory_path):
                os.makedirs(logs_directory_path, exist_ok=True)
        else:
            send_slack_alert("main_directory_path does not exist")
            print("main_directory_path does not exist")
            exit("main_directory_path does not exist")
        ####################################################################################################################
        ######################## logs date directory creation inside the main_directory_path ###############################
        ####################################################################################################################
        ####################################################################################################################

        #
        #
        #
        #

        ####################################################################################################################
        ####################################################################################################################
        ############################## Search container log path and push log files ########################################
        ####################################################################################################################
        try:
            if logs_directory_path:
                print(
                    f"Searching logs created on {date_of_logs__string} at the path '{container_logs_path}'...\n"
                )
                datewise_search_and_push(
                    container_logs_path, logs_directory_path, date_of_logs__string
                )
            else:
                send_slack_alert("logs_directory_path does not exist")
                print("logs_directory_path does not exist")
                exit("logs_directory_path does not exist")
        except Exception as e:
            send_slack_alert(
                f"Failed to search and push log files from container log path. Error: {str(e)}"
            )
            print(
                f"Failed to search and push log files from container log path. Error: {str(e)}"
            )
            exit(
                f"Failed to search and push log files from container log path. Error: {str(e)}"
            )
        ####################################################################################################################
        ############################## Search container log path and push log files ########################################
        ####################################################################################################################
        ####################################################################################################################

        #
        #
        #
        #

        ####################################################################################################################
        ####################################################################################################################
        ############################## Search container log path (ARCHIVED) and push log files #############################
        ####################################################################################################################
        try:
            if logs_directory_path:
                print(
                    f"Searching logs created on {date_of_logs__string} at the path '{container_logs_path_archive}'...\n"
                )
                modified_date_of_logs__string = date_of_logs.strftime(
                    "%Y-%m-%d"
                )  # Changing date string formate to match archived logs file name
                datewise_search_and_push_archive(
                    container_logs_path_archive,
                    logs_directory_path,
                    modified_date_of_logs__string,
                )
            else:
                send_slack_alert("logs_directory_path does not exist")
                print("logs_directory_path does not exist")
                exit("logs_directory_path does not exist")
        except Exception as e:
            send_slack_alert(
                f"Failed to search and push log files (archived) from container log path. Error: {str(e)}"
            )
            print(
                f"Failed to search and push log files (archived) from container log path. Error: {str(e)}"
            )
            exit(
                f"Failed to search and push log files (archived) from container log path. Error: {str(e)}"
            )
        ####################################################################################################################
        ############################## Search container log path (ARCHIVED) and push log files #############################
        ####################################################################################################################
        ####################################################################################################################

        #
        #
        #
        #

        ####################################################################################################################
        ####################################################################################################################
        ############################## Extra logs cleanup in case of today=starting_day_of_log_archival ####################
        ####################################################################################################################
        if current_date.strftime("%A") == starting_day_of_log_archival:
            try:
                extra_logs_path = os.path.join(
                    previous_main_directory_path, "extra_logs"
                )
                if not os.path.exists(extra_logs_path):
                    os.makedirs(extra_logs_path, exist_ok=True)
                print(
                    f"Cleaning up extra logs older than {date_of_logs} and pushing in '{extra_logs_path}' directory...\n"
                )
                # In these functions, only the pattern will be matched and the date won't be considered
                cleanup_logs_older_than_date(
                    date_of_logs, container_logs_path, extra_logs_path
                )
                cleanup_logs_older_than_date(
                    date_of_logs, container_logs_path_archive, extra_logs_path
                )

            except Exception as e:
                send_slack_alert(str(e))
                print(f"Error: {str(e)}")
                exit(f"Error: {str(e)}")

        ####################################################################################################################
        ############################## Extra logs cleanup in case of today=starting_day_of_log_archival ####################
        ####################################################################################################################
        ####################################################################################################################

        #
        #
        #
        #

        ####################################################################################################################
        ####################################################################################################################
        ############################################ Compressing processed logs ############################################
        ####################################################################################################################
        if current_date.strftime("%A") == starting_day_of_log_archival:
            print(
                f"\n\n######################## Compressing '{previous_main_directory_path}' directory and storing at {processed_logs_path} ########################\n"
            )
            compress_directory(previous_main_directory_path, processed_logs_path)
        ####################################################################################################################
        ############################################ Compressing processed logs ############################################
        ####################################################################################################################
        ####################################################################################################################

    except Exception as e:
        send_slack_alert(str(e))
        print(f"Error: {str(e)}")
        exit(f"Error: {str(e)}")


if __name__ == "__main__":
    main()
