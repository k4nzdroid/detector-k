#!/bin/sh

_log_date() {
	date "+%Y-%m-%d %H:%M:%S"
}

log_debug() {
    echo "[D] [$(_log_date)] $1"
}

log_info() {
	echo "[I] [$(_log_date)] $1" | grep -E --color '.+'
}
log_warn() {
	echo "[W] [$(_log_date)] $1" | grep -E --color '.+'
}
log_error() {
	echo "[E] [$(_log_date)] $1" | grep -E --color '.+'
}
