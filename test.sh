#!/usr/bin/bash

set pass "tbao123"
expect "New password:"
send "$pass\r"
expect "Retype new password:"
send "$pass\r"
expect eof
