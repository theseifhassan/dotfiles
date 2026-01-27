#!/bin/sh
# Returns 0 if lid open, 1 if closed
# Used by pam_exec to skip fingerprint auth when lid is closed (docked)
LID="/proc/acpi/button/lid/LID0/state"
[ ! -f "$LID" ] && exit 0
grep -q "open" "$LID"
