# -*- coding: utf-8 -*-
import os
import shutil
from datetime import datetime
from functions import log
from distutils.dir_util import copy_tree


class Delft3D_501002163 (object):
    def __init__(self, parameters):
        self.parameters = parameters
        self.version = "5.01.00.2163"
        self.static = "delft3d/5.01.00.2163/static"
        self.files = [
                {"filename": 'CloudCoverage.amc', "parameter": "CLCT", "quantity": "cloudiness", "unit": "%", "adjust": 0},
                {"filename": 'Pressure.amp', "parameter": "PMSL", "quantity": "air_pressure", "unit": "Pa", "adjust": 0},
                {"filename": 'RelativeHumidity.amr', "parameter": "RELHUM_2M", "quantity": "relative_humidity", "unit": "%", "adjust": 0},
                {"filename": 'ShortwaveFlux.ams', "parameter": "GLOB", "quantity": "sw_radiation_flux", "unit": "W/m2", "adjust": 0},
                {"filename": 'Temperature.amt', "parameter": "T_2M", "quantity": "air_temperature", "unit": "Celsius", "adjust": -273.15},
                {"filename": 'WindU.amu', "parameter": "U", "quantity": "x_wind", "unit": "m s-1", "adjust": 0},
                {"filename": 'WindV.amv', "parameter": "V", "quantity": "y_wind", "unit": "m s-1", "adjust": 0},
            ]
        self.log = log(parameters["log_name"], parameters["log_path"])
        self.log.initialise("Initialising hydrodynamic simulation {} using {}".format(parameters["model"], parameters["setup"].replace("_", " ")))
        self.log.initialise("Simulating from {} to {}".format(parameters["start_date"], parameters["end_date"]))

    def process(self):
        self.copy_static_data()
        self.collect_restart_file()
        self.update_control_file()
        self.weather_data_files()

    def copy_static_data(self):
        self.log.log("Copying static data to simulation folder.")
        copy_tree(os.path.join(self.static, self.parameters["model"]), self.parameters["simulation_folder"])

    def collect_restart_file(self):
        self.log.log("Collecting restart file.")
        file, start_date = self.collect_restart_file_local_storage()
        self.parameters["start_date"] = start_date
        self.log.log("Start date adjusted to {} to match restart file.".format(start_date), indent=1)
        shutil.copyfile(file, os.path.join(self.parameters["simulation_folder"], "tri-rst.Simulation_Web_rst.000000"))

    def collect_restart_file_local_storage(self):
        files = os.listdir(self.parameters["restart_files"])
        files.sort()
        dates = [self.parameters["start_date"].timestamp() - datetime.strptime(x.split(".")[-2], '%Y%m%d').timestamp() for x in files]
        dates = [x for x in dates if x > 0]
        file = files[dates.index(min(dates))]
        date = datetime.strptime(file.split(".")[-2], '%Y%m%d')
        return os.path.join(self.parameters["restart_files"], file), date

    def update_control_file(self, origin=datetime(2008, 3, 1), period=180):
        self.log.log("Updating control file dates.")
        with open(os.path.join(self.parameters["simulation_folder"], "Simulation_Web.mdf"), 'r') as f:
            lines = f.readlines()
        start = "{:.7e}".format((self.parameters["start_date"] - origin).total_seconds() / 60)
        end = "{:.7e}".format(((self.parameters["end_date"] - origin).total_seconds() / 60) - period)

        for i in range(len(lines)):
            if "Tstart" in lines[i]:
                lines[i] = "Tstart = " + start + "\n"
            if "Tstop" in lines[i]:
                lines[i] = "Tstop = " + end + "\n"
            if lines[i].split(" ")[0] in ["Flmap", "Flhis", "Flwq"]:
                lines[i] = "{} = {} {} {}\n".format(lines[i].split(" ")[0], start, str(period), end)

        with open(os.path.join(self.parameters["simulation_folder"], "Simulation_Web.mdf"), 'w') as f:
            f.writelines(lines)

    def weather_data_files(self):
        self.log.log("Creating weather data files.")
        self.create_weather_data_local_storage()

    def create_weather_data_local_storage(self):
        print("Testing")
