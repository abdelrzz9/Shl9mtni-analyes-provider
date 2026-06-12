import hashlib
import json
import threading
import time
from typing import Any, Optional

from .config import settings


class MathCache:
    def __init__(self):
        self._lock = threading.RLock()
        self._cache: dict[str, tuple[Any, float]] = {}
        self._max_size = settings.cache_max_size
        self._ttl = settings.cache_ttl_seconds
        self._enabled = settings.cache_enabled

    def _make_key(self, operation: str, *args, **kwargs) -> str:
        raw = json.dumps({"op": operation, "args": args, "kwargs": kwargs}, sort_keys=True)
        return hashlib.sha256(raw.encode()).hexdigest()

    def get(self, operation: str, *args, **kwargs) -> Optional[Any]:
        if not self._enabled:
            return None
        key = self._make_key(operation, *args, **kwargs)
        with self._lock:
            entry = self._cache.get(key)
            if entry is None:
                return None
            value, timestamp = entry
            if time.monotonic() - timestamp > self._ttl:
                del self._cache[key]
                return None
            return value

    def set(self, operation: str, value: Any, *args, **kwargs) -> None:
        if not self._enabled:
            return
        key = self._make_key(operation, *args, **kwargs)
        with self._lock:
            if len(self._cache) >= self._max_size:
                oldest_key = min(self._cache.keys(), key=lambda k: self._cache[k][1])
                del self._cache[oldest_key]
            self._cache[key] = (value, time.monotonic())

    def clear(self) -> None:
        with self._lock:
            self._cache.clear()

    @property
    def size(self) -> int:
        with self._lock:
            return len(self._cache)


math_cache = MathCache()
