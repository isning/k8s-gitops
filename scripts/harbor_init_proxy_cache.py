#!/usr/bin/env python3
"""Initialize Harbor proxy cache registries and projects.

Usage:
    HARBOR_ROBOT_NAME='robot$my-bot' HARBOR_ROBOT_SECRET=... \
        python3 scripts/harbor_init_proxy_cache.py \
            --harbor-url https://harbor.isning.moe \
            --config scripts/harbor_proxy_cache_config.example.json
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from typing import Any


_NATIVE_PROVIDER_DEFAULT_URL: dict[str, str] = {
    "docker-hub": "https://hub.docker.com",
    "github-ghcr": "https://github.com",
    "quay": "https://quay.io",
    "gcr": "https://gcr.io",
}

_NATIVE_PROVIDER_DOCKER_REGISTRY_FALLBACK_URL: dict[str, str] = {
    "github-ghcr": "https://ghcr.io",
    "quay": "https://quay.io",
    "gcr": "https://gcr.io",
}


def _request_json(
    method: str,
    url: str,
    robot_name: str,
    robot_secret: str,
    user_agent: str,
    payload: dict[str, Any] | None = None,
    accepted_codes: tuple[int, ...] = (200,),
) -> Any:
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")

    req = urllib.request.Request(url=url, method=method, data=data)
    req.add_header("Accept", "application/json")
    req.add_header("Content-Type", "application/json")
    req.add_header("User-Agent", user_agent)

    credentials = f"{robot_name}:{robot_secret}".encode("utf-8")
    import base64

    req.add_header("Authorization", "Basic " + base64.b64encode(credentials).decode("ascii"))

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            if resp.status not in accepted_codes:
                raise RuntimeError(f"Unexpected status {resp.status} for {method} {url}")
            body = resp.read().decode("utf-8")
            return json.loads(body) if body else None
    except urllib.error.HTTPError as exc:
        if exc.code in accepted_codes:
            body = exc.read().decode("utf-8") if exc.fp else ""
            return json.loads(body) if body else None
        detail = exc.read().decode("utf-8") if exc.fp else ""
        if exc.code == 401:
            raise RuntimeError(
                "HTTP 401 unauthorized. Harbor robot account auth failed. "
                "Check HARBOR_ROBOT_NAME/HARBOR_ROBOT_SECRET and robot permissions. "
                f"Request: {method} {url}. Response: {detail}"
            ) from exc
        if exc.code == 500 and "/api/v2.0/registries" in url and method.upper() == "POST":
            raise RuntimeError(
                "HTTP 500 while creating Harbor upstream registry. "
                "For native providers (github-ghcr/gcr/quay/docker-hub), Harbor may require credentials or reject invalid upstream settings. "
                "Try setting access_key_env/access_secret_env for that registry or switch provider to docker-registry if you need anonymous mode. "
                f"Request: {method} {url}. Response: {detail}"
            ) from exc
        raise RuntimeError(f"HTTP {exc.code} on {method} {url}: {detail}") from exc


def _list_registries(
    base_url: str,
    robot_name: str,
    robot_secret: str,
    user_agent: str,
) -> list[dict[str, Any]]:
    url = f"{base_url}/api/v2.0/registries?page=1&page_size=100"
    return _request_json(
        "GET",
        url,
        robot_name,
        robot_secret,
        user_agent,
        accepted_codes=(200,),
    )


def _list_projects(
    base_url: str,
    robot_name: str,
    robot_secret: str,
    user_agent: str,
) -> list[dict[str, Any]]:
    url = f"{base_url}/api/v2.0/projects?page=1&page_size=100&with_detail=true"
    return _request_json(
        "GET",
        url,
        robot_name,
        robot_secret,
        user_agent,
        accepted_codes=(200,),
    )


def _find_registry_id(registries: list[dict[str, Any]], name: str) -> int | None:
    for item in registries:
        if item.get("name") == name:
            return int(item["id"])
    return None


def _find_registry(registries: list[dict[str, Any]], name: str) -> dict[str, Any] | None:
    for item in registries:
        if item.get("name") == name:
            return item
    return None


def _find_project(projects: list[dict[str, Any]], name: str) -> dict[str, Any] | None:
    for item in projects:
        if item.get("name") == name:
            return item
    return None


def _create_registry(
    base_url: str,
    robot_name: str,
    robot_secret: str,
    user_agent: str,
    item: dict[str, Any],
) -> None:
    url = f"{base_url}/api/v2.0/registries"
    provider = item["provider"]
    has_credential_fields = bool(item.get("access_key_env") and item.get("access_secret_env"))

    payload: dict[str, Any] = {
        "name": item["name"],
        "type": provider,
        "insecure": bool(item.get("insecure", False)),
    }

    if provider in _NATIVE_PROVIDER_DEFAULT_URL:
        native_url = _NATIVE_PROVIDER_DEFAULT_URL[provider]
        payload["url"] = native_url

        # For Harbor native providers, prefer Harbor's built-in upstream endpoint.
        configured_endpoint = str(item.get("endpoint", "")).strip()
        if configured_endpoint and configured_endpoint.rstrip("/") != native_url:
            print(
                f"Warning: registry '{item['name']}' provider '{provider}' ignores custom endpoint "
                f"'{configured_endpoint}'. Using native upstream '{native_url}'.",
                file=sys.stderr,
            )
    else:
        endpoint = str(item.get("endpoint", "")).strip()
        if not endpoint:
            raise RuntimeError(
                f"Registry '{item['name']}' provider '{provider}' requires non-empty endpoint."
            )
        payload["url"] = endpoint

    credential: dict[str, str] = {"type": item.get("credential_type", "basic")}
    access_key_env = item.get("access_key_env")
    access_secret_env = item.get("access_secret_env")
    if access_key_env and access_secret_env:
        access_key = os.getenv(access_key_env, "")
        access_secret = os.getenv(access_secret_env, "")
        if access_key and access_secret:
            credential["access_key"] = access_key
            credential["access_secret"] = access_secret
        else:
            raise RuntimeError(
                "Missing upstream registry credentials for "
                f"'{item['name']}'. Expected env vars: {access_key_env}, {access_secret_env}"
            )

    if len(credential) > 1:
        payload["credential"] = credential

    try:
        _request_json(
            "POST",
            url,
            robot_name,
            robot_secret,
            user_agent,
            payload=payload,
            accepted_codes=(201, 409),
        )
    except RuntimeError as exc:
        # Some Harbor versions fail on anonymous native providers; fall back to docker-registry.
        fallback_url = _NATIVE_PROVIDER_DOCKER_REGISTRY_FALLBACK_URL.get(provider)
        if (
            fallback_url
            and not has_credential_fields
            and "HTTP 500 while creating Harbor upstream registry" in str(exc)
        ):
            print(
                f"Warning: native provider '{provider}' failed for '{item['name']}', "
                "falling back to docker-registry.",
                file=sys.stderr,
            )
            fallback_payload: dict[str, Any] = {
                "name": item["name"],
                "type": "docker-registry",
                "url": fallback_url,
                "insecure": bool(item.get("insecure", False)),
            }
            _request_json(
                "POST",
                url,
                robot_name,
                robot_secret,
                user_agent,
                payload=fallback_payload,
                accepted_codes=(201, 409),
            )
            return
        raise


def _create_project(
    base_url: str,
    robot_name: str,
    robot_secret: str,
    user_agent: str,
    item: dict[str, Any],
    registry_id: int,
) -> None:
    url = f"{base_url}/api/v2.0/projects"
    is_public = bool(item.get("public", True))
    payload = {
        "project_name": item["name"],
        "registry_id": registry_id,
        "metadata": {"public": "true" if is_public else "false"},
        "storage_limit": int(item.get("storage_limit", -1)),
    }
    _request_json(
        "POST",
        url,
        robot_name,
        robot_secret,
        user_agent,
        payload=payload,
        accepted_codes=(201, 409),
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Initialize Harbor proxy cache projects")
    parser.add_argument("--harbor-url", required=True, help="Harbor base URL, e.g. https://harbor.example.com")
    parser.add_argument(
        "--robot-name",
        default=os.getenv("HARBOR_ROBOT_NAME", ""),
        help="Harbor robot account name",
    )
    parser.add_argument(
        "--robot-secret",
        default=os.getenv("HARBOR_ROBOT_SECRET", ""),
        help="Harbor robot account secret",
    )
    parser.add_argument(
        "--user-agent",
        default=os.getenv(
            "HARBOR_USER_AGENT",
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        ),
        help="HTTP User-Agent for Harbor API requests (or set HARBOR_USER_AGENT)",
    )
    parser.add_argument("--config", required=True, help="Path to JSON config file")
    args = parser.parse_args()

    if not args.robot_name or not args.robot_secret:
        print(
            "Error: missing robot credentials. Set --robot-name/--robot-secret or "
            "HARBOR_ROBOT_NAME/HARBOR_ROBOT_SECRET.",
            file=sys.stderr,
        )
        return 2

    with open(args.config, "r", encoding="utf-8") as f:
        config = json.load(f)

    base_url = args.harbor_url.rstrip("/")

    print(f"Using Harbor robot account: {args.robot_name}")

    registry_items = config.get("registries", [])
    project_items = config.get("projects", [])

    if not registry_items:
        print("No registries configured, nothing to do.")
        return 0

    # Step 1: create or reuse upstream registries
    for item in registry_items:
        name = item["name"]
        registries = _list_registries(
            base_url,
            args.robot_name,
            args.robot_secret,
            args.user_agent,
        )
        existing_registry = _find_registry(registries, name)
        registry_id = int(existing_registry["id"]) if existing_registry is not None else None
        if registry_id is None:
            print(f"Creating registry: {name}")
            _create_registry(
                base_url,
                args.robot_name,
                args.robot_secret,
                args.user_agent,
                item,
            )
        else:
            expected_type = item["provider"]
            if expected_type in _NATIVE_PROVIDER_DEFAULT_URL:
                expected_endpoint = _NATIVE_PROVIDER_DEFAULT_URL[expected_type].rstrip("/")
            else:
                expected_endpoint = str(item.get("endpoint", "")).rstrip("/")
            existing_type = str(existing_registry.get("type", ""))
            existing_endpoint = str(existing_registry.get("url", "")).rstrip("/")
            compatible_fallback = False
            fallback_url = _NATIVE_PROVIDER_DOCKER_REGISTRY_FALLBACK_URL.get(expected_type, "").rstrip("/")
            if fallback_url and existing_type == "docker-registry" and existing_endpoint == fallback_url:
                compatible_fallback = True

            if (existing_type != expected_type or existing_endpoint != expected_endpoint) and not compatible_fallback:
                raise RuntimeError(
                    f"Registry '{name}' already exists but differs from config. "
                    f"existing(type={existing_type}, url={existing_endpoint}) vs "
                    f"expected(type={expected_type}, url={expected_endpoint}). "
                    "Delete/recreate it in Harbor UI or use a new registry name in config."
                )
            if compatible_fallback:
                print(
                    f"Registry already exists with docker-registry fallback: {name} (id={registry_id})",
                    file=sys.stderr,
                )
            else:
                print(f"Registry already exists: {name} (id={registry_id})")

    # Step 2: create proxy cache projects bound to registry ids
    registries = _list_registries(
        base_url,
        args.robot_name,
        args.robot_secret,
        args.user_agent,
    )
    projects = _list_projects(
        base_url,
        args.robot_name,
        args.robot_secret,
        args.user_agent,
    )

    for item in project_items:
        name = item["name"]
        registry_name = item["registry"]
        registry_id = _find_registry_id(registries, registry_name)
        if registry_id is None:
            raise RuntimeError(
                f"Registry '{registry_name}' not found for project '{name}'. "
                "Check config.registries entries."
            )

        if _find_project(projects, name) is not None:
            print(f"Project already exists: {name}")
            continue

        print(f"Creating proxy cache project: {name} -> registry '{registry_name}' (id={registry_id})")
        _create_project(
            base_url,
            args.robot_name,
            args.robot_secret,
            args.user_agent,
            item,
            registry_id,
        )

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
