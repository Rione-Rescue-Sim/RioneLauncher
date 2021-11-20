import inspect
import os


def ERROR(comment: str):
    frame = inspect.currentframe().f_back
    return print("[ERROR]", "\n\t", comment, os.path.basename(frame.f_code.co_filename), frame.f_code.co_name, frame.f_lineno)
