# -*- coding: utf-8 -*-
import os
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

    def process(self):
        self.copy_static_data()
        self.collect_restart_file()
        self.weather_data_files()

    def copy_static_data(self):
        self.log.log("Copying static data to simulation folder.")
        copy_tree(os.path.join(self.static, self.parameters["model"]), self.parameters["simulation_folder"])
        self.log.log("Copied files.", indent=1)

    def collect_restart_file(self):
        self.log.log("Collecting restart file.")

    def adjust_static_files(self):
        self.log.log("Adjusting static files.")

    def weather_data_files(self):
        self.log.log("Creating weather data files.")


