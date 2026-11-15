load test_helper

setup() {
  setup_yazi stats
  echo 'require("stats"):setup { starship = true }' >"$YAZI_CONFIG_HOME/init.lua"
  echo hello >"$WORK/hello.txt"
}

teardown() { stop_yazi; }

@test "the status line shows the hovered file" {
  start_yazi
  assert_healthy
  screen | grep -q "hello.txt"
}

@test "moving through the folders does not break Yazi" {
  mkdir -p "$WORK/sub"
  echo x >"$WORK/sub/file.txt"
  start_yazi
  send_keys l
  send_keys h
  assert_healthy
}
