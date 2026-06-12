import logging
import sys

from .config import settings


def setup_logging() -> logging.Logger:
    level = logging.DEBUG if settings.log_level == "debug" else logging.INFO
    if settings.log_level == "warn":
        level = logging.WARNING
    elif settings.log_level == "error":
        level = logging.ERROR

    formatter = logging.Formatter(
        "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
        datefmt="%Y-%m-%dT%H:%M:%S%z",
    )

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)

    logger = logging.getLogger("mathverse-engine")
    logger.setLevel(level)
    logger.addHandler(handler)
    logger.propagate = False

    return logger


logger = setup_logging()
