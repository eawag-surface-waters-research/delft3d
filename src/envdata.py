# -*- coding: utf-8 -*-
from functions import log


class Delft3D_501002163 (object):
    def __init__(self, parameters):
        self.parameters = parameters
        self.version = "5.01.00.2163"
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

    def create_input_files(self):
        self.log.log("Creating input files.")

