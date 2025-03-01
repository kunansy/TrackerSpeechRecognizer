import logging
from pathlib import Path

from environs import Env


env = Env()
env.read_env()

DATA_DIR = Path("data/")
DATA_DIR.mkdir(parents=True, exist_ok=True)

API_VERSION = "0.1.0"
if (version_file := Path("VERSION")).exists():
    API_VERSION = version_file.read_text().strip()

API_DEBUG = env.bool("API_DEBUG", False)

with env.prefixed("LOGGER_"):
    LOGGER_NAME = env("NAME", "SpeechRecognizer")
    LOGGER_LEVEL = env.log_level("LEVEL", logging.DEBUG)
