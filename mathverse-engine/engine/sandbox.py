import threading
from contextlib import contextmanager
from typing import Any, Callable


class TimeoutError(Exception):
    pass


@contextmanager
def timeout(seconds: int):
    if seconds <= 0:
        yield
        return

    result: list[Any] = []
    exception: list[Exception] = []

    def worker():
        try:
            yield
        except Exception as e:
            exception.append(e)

    timer = threading.Timer(seconds, lambda: result.append(True))
    timer.start()
    try:
        yield
    finally:
        timer.cancel()
        if result:
            raise TimeoutError(f"execution timed out after {seconds} seconds")


class ExpressionValidator:
    MAX_LENGTH = 10000
    BLOCKED_KEYWORDS = [
        "__import__",
        "eval",
        "exec",
        "compile",
        "open",
        "file",
        "import",
        "os.",
        "sys.",
        "subprocess",
        "shutil",
        "__builtins__",
        "__class__",
        "__base__",
        "__subclasses__",
    ]

    @classmethod
    def validate(cls, expression: str) -> None:
        if not expression or not expression.strip():
            raise ValueError("expression cannot be empty")

        if len(expression) > cls.MAX_LENGTH:
            raise ValueError(
                f"expression too long ({len(expression)} > {cls.MAX_LENGTH})"
            )

        lower = expression.lower()
        for keyword in cls.BLOCKED_KEYWORDS:
            if keyword in lower:
                raise ValueError(f"expression contains blocked pattern: {keyword}")


def sandboxed_execute(
    func: Callable,
    args: tuple = (),
    kwargs: dict = None,
    timeout_seconds: int = 30,
) -> Any:
    if kwargs is None:
        kwargs = {}

    result: list[Any] = []
    error: list[Exception] = []

    def target():
        try:
            res = func(*args, **kwargs)
            result.append(res)
        except Exception as e:
            error.append(e)

    thread = threading.Thread(target=target, daemon=True)
    thread.start()
    thread.join(timeout_seconds)

    if thread.is_alive():
        raise TimeoutError(f"execution timed out after {timeout_seconds} seconds")

    if error:
        raise error[0]

    return result[0]
