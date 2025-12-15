#!/usr/bin/bash

# Mật khẩu mới
PASS="tbao123"
printf "%s\n%s\n" "$PASS" "$PASS" | passwd
