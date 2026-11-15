load test_helper

setup() {
  setup_yazi starship
  printf 'add_newline = false\nformat = "PROMPT-MARK"\n' >"$BATS_TEST_TMPDIR/starship.toml"
  echo "require(\"starship\"):setup { starship = true, starship_config = \"$BATS_TEST_TMPDIR/starship.toml\" }" >"$YAZI_CONFIG_HOME/init.lua"
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

@test "the prompt of starship comes from the configuration that is given" {
  start_yazi
  sleep 2
  assert_screen "PROMPT-MARK"
}
