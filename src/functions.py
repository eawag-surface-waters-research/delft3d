import os
import yaml
from datetime import datetime


def parse_parameters(file):
    if not os.path.isfile(file):
        raise Exception("File doesn't exist: {}".format(file))
    if ".yaml" not in file:
        raise Exception("File must be a .yaml file.")

    required = [{"name": "start_date", "default": False, "type": valid_date},
                {"name": "end_date", "default": False, "type": valid_date},
                {"name": "model", "default": False, "type": valid_string},
                {"name": "log_name", "default": "log", "type": valid_string},
                {"name": "log_path", "default": "", "type": valid_path},
                {"name": "setup", "default": False, "type": valid_string},
                {"name": "simulation_folder", "default": False, "type": valid_path},
                {"name": "env_data", "default": "local", "type": valid_string},
                ]
    try:
        with open(file, "r") as f:
            parameters = yaml.load(f, Loader=yaml.FullLoader)
    except Exception as e:
        print(e)
        raise Exception("Failed to parse input yaml file.")

    for i in range(len(required)):
        key = required[i]["name"]
        parameters[key] = required[i]["type"](key, parameters, required[i]["default"])

    print(parameters)

    return parameters


def valid_date(key, parameters, default):
    if key not in parameters:
        if default == False:
            raise Exception("A valid key: {} format YYYYMMDD must be provided.".format(key))
        else:
            return default
    try:
        return datetime.strptime(parameters[key], '%Y%m%d')
    except:
        raise Exception("A valid key: {} format YYYYMMDD must be provided.".format(key))


def valid_string(key, parameters, default):
    if key not in parameters:
        if default == False:
            raise Exception("A valid key: {} format string must be provided.".format(key))
        else:
            return default
    if isinstance(parameters[key], str):
        return parameters[key]
    else:
        raise Exception("A valid key: {} format string must be provided.".format(key))


def valid_path(key, parameters, default):
    if key not in parameters:
        if default == False:
            raise Exception("A valid key: {} format path must be provided.".format(key))
        else:
            return default
    if os.path.isdir(parameters[key]):
        return parameters[key]
    else:
        raise Exception("A valid key: {} format path must be provided.".format(key))


def error(string):
    print('\033[91m' + string + '\033[0m')


class log(object):
    def __init__(self, name, path=""):
        self.name = name + datetime.now().strftime("_%Y%m%d_%H%M%S") + ".txt"
        self.path = os.path.join(path, self.name)

    def log(self, string, indent=0):
        out = datetime.now().strftime("%H:%M:%S.%f") + (" " * 3 * (indent + 1)) + string
        print(out)
        with open(self.path, "a") as file:
            file.write(out + "\n")

    def initialise(self, string):
        out = "****** " + string + " ******"
        print('\033[92m' + out + '\033[0m')
        print("Logging to: {}".format(self.path))
        with open(self.path, "a") as file:
            file.write(out + "\n")

    def warning(self, string, indent=0):
        out = datetime.now().strftime("%H:%M:%S.%f") + (" " * 3 * (indent + 1)) + "WARNING: " + string
        print('\033[93m' + out + '\033[0m')
        with open(self.path, "a") as file:
            file.write(out + "\n")

    def error(self, string, indent=0):
        out = datetime.now().strftime("%H:%M:%S.%f") + (" " * 3 * (indent + 1)) + "ERROR: " + string
        print('\033[91m' + out + '\033[0m')
        with open(self.path, "a") as file:
            file.write(out + "\n")
