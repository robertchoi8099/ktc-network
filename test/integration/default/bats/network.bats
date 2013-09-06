# vim: ft=sh:

@test "network-api is running" {
  netstat -tan | grep 9696
}
