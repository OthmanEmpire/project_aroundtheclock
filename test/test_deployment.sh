#!/bin/bash
@test "Check python3 installed" {
  run dpkg -s python3 &> /dev/null
  [ "$status" -eq 0 ]
}


@test "Check python3 dependencies installed" {
  run dpkg -s python3-pip &> /dev/null
  [ "$status" -eq 0 ]

  run dpkg -s python3-venv &> /dev/null
  [ "$status" -eq 0 ]
}


@test "Check OS network library installed" {
  run dpkg -s dsniff &> /dev/null
  [ "$status" -eq 0 ]
}


@test "Check python virtual environment created" {
  run ls virtual/
  [ "$status" -eq 0 ]
}


@test "Check aroundtheclock user exists" {
  result=$(cat /etc/passwd | grep -c aroundtheclock)
  [ "$result" -eq 1 ]
}


@test "Check aroundtheclock user permissions" {
  entry1="Cmnd_Alias AROUNDTHECLOCK_CMDS = /usr/local/bin/aroundtheclock"
  entry2="aroundtheclock ALL=(ALL) NOPASSWD: AROUNDTHECLOCK_CMDS"
  result1=$(grep -c "$entry1" /etc/sudoers)
  result2=$(grep -c "$entry2" /etc/sudoers)

  [ "$result1" -eq 1 ]
  [ "$result2" -eq 1 ]
}


@test "Check aroundtheclock user is assigned no default shell" {
  result=$(cat /etc/passwd | grep -c aroundtheclock:/bin/false)
  [ "$result" -eq 1 ]
}


@test "Check aroundtheclock executable installed" {
  run whereis aroundtheclock
  [ "$status" -eq 0 ]
}


@test "Check aroundtheclock executable permissions" {
  location=$(whereis aroundtheclock | cut -d " " -f 2)
  result1=$(getfacl "$location" | grep -c "owner: root" )
  result2=$(getfacl "$location" | grep -c "group: root")
  result3=$(getfacl "$location" | grep -c "group::---")
  result4=$(getfacl "$location" | grep -c "other::---")
  result5=$(getfacl "$location" | wc -l)

  [ "$result1" -eq 1 ]
  [ "$result2" -eq 1 ]
  [ "$result3" -eq 1 ]
  [ "$result4" -eq 1 ]
  # Ensure no setfacl permissions applied (includes final blank line)
  [ "$result5" -eq 7 ]
}


@test "Check aroundtheclock.service config file installed" {
  run ls /lib/systemd/system/aroundtheclock.service
  [ "$status" -eq 0 ]
}


@test "Check aroundtheclock.service exists" {
  run systemctl status aroundtheclock.service > /dev/null
  [ "$status" -ne 4 ]
}


@test "Check aroundtheclock.service is running" {
  run systemctl status aroundtheclock.service > /dev/null
  [ "$status" -eq 0 ]
}


@test "Check aroundtheclock.service enabled at boot" {
  result=$(systemctl list-unit-files | grep aroundtheclock | grep -c enabled)
  [ "$result" -eq 1 ]
}
