import inspect
import os


class criticalError(Exception):
    # シミュレーションを実行できない致命的なエラー
    # 実行済みのプログラムをkillする必要があるので作成
    pass


def ERROR(comment=""):
    frame = inspect.currentframe().f_back
    return print("[ERROR]", "\n\t", comment, os.path.basename(frame.f_code.co_filename), frame.f_code.co_name, frame.f_lineno)
