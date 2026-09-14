"""
HTTP Basic authentication for the Web interface.

Credentials are read from the environment only (never from the config file),
because the config file is dumped to disk by the /api/save endpoint and copied
out of the container by startDocker.sh -g.

    WEB_UI_USERNAME   username required to access the UI
    WEB_UI_PASSWORD   password required to access the UI
    WEB_UI_REALM      optional realm shown by the browser prompt

If username or password are missing, authentication is disabled and a warning
is logged, so existing deployments keep working.
"""

from __future__ import annotations

import base64
import binascii
import logging
import os
import secrets

from starlette.datastructures import Headers
from starlette.responses import PlainTextResponse
from starlette.types import ASGIApp, Receive, Scope, Send

DEFAULT_REALM = "TikTok Live Monitor"


def get_credentials() -> tuple[str, str] | None:
    """Return (username, password) from the environment, or None if unset"""
    username = os.environ.get("WEB_UI_USERNAME", "").strip()
    password = os.environ.get("WEB_UI_PASSWORD", "")

    if not username or not password:
        return None

    return username, password


class BasicAuthMiddleware:
    """
    Pure ASGI middleware so that every request is covered, including the
    StaticFiles mount, which is not seen by route dependencies.
    """

    def __init__(self, app: ASGIApp, username: str, password: str, realm: str = DEFAULT_REALM):
        self.app = app
        # Kept as bytes, secrets.compare_digest refuses non ASCII strings
        self.username = username.encode("utf-8")
        self.password = password.encode("utf-8")
        self.realm = realm
        self.logger = logging.getLogger(__name__)

    def _is_authorized(self, header: str | None) -> bool:
        if not header:
            return False

        scheme, _, credentials = header.partition(" ")
        if scheme.lower() != "basic" or not credentials:
            return False

        try:
            decoded = base64.b64decode(credentials, validate=True).decode("utf-8")
        except (binascii.Error, UnicodeDecodeError):
            return False

        username, separator, password = decoded.partition(":")
        if not separator:
            return False

        # Compare both halves unconditionally to avoid leaking which one matched
        user_ok = secrets.compare_digest(username.encode("utf-8"), self.username)
        pass_ok = secrets.compare_digest(password.encode("utf-8"), self.password)

        return user_ok and pass_ok

    async def __call__(self, scope: Scope, receive: Receive, send: Send):
        if scope["type"] not in ("http", "websocket"):
            await self.app(scope, receive, send)
            return

        if self._is_authorized(Headers(scope=scope).get("authorization")):
            await self.app(scope, receive, send)
            return

        if scope["type"] == "websocket":
            await send({"type": "websocket.close", "code": 1008})
            return

        client = scope.get("client")
        self.logger.warning(f"🔒 Unauthorized request to {scope.get('path')} from {client[0] if client else 'unknown'}")

        response = PlainTextResponse(
            "Unauthorized",
            status_code=401,
            headers={"WWW-Authenticate": f'Basic realm="{self.realm}", charset="UTF-8"'},
        )
        await response(scope, receive, send)
