#!/bin/bash


TEST_CLEANUP=":"

## test_init() {
typeset -i test_num=0 # increments w/each test_define
typeset test_msg  # prefix: "Test nr#"  for msgs
typeset test_name # test name given 
typeset test_sanename # test name with all whitespace (and alike) replaced by '_'
typeset test_filename
typeset -i test_n_pass=0
typeset -i test_n_fail=0
typeset test_str_fail=""
typeset test_str_pass=""
## }

test_report() {
  test -n "$test_str_fail" && test_str_fail="($test_str_fail)"
  test -n "$test_str_pass" && test_str_pass="($test_str_pass)"
  echo "= TEST REPORT ="
  echo "Ntests PASS: " $test_n_pass  $test_str_pass
  echo "Ntests FAIL: " $test_n_fail  $test_str_fail
  echo "Ntests TOTL: " $test_num
}
say () {
  echo -e "$@" >&3
} 
notice() {
  say "NOTICE: $@"
}
err () {
  echo -e "${_P:=}ERROR: $@" >&4
}
debug () {
  local x=
  case "$1" in -*) x="$1";shift;; esac
  echo $x -e "${_P:=}DEBUG: $@" >&4
}
test_define() {
  test_bg_cleanup
  test_name="$*"
  test_sanename="$(echo -n $test_name| tr -c '[[=-=]A-Za-z0-9._]' _ )"
  test_num=test_num+1
  test_msg="$(printf "Test %02d" $test_num)"
  test_filename=$LIBTEST_OUTPUT_DIR/$USER-test-out-$test_sanename
  > $test_filename
}
test_expect_success () {
  local msg="$1" 
  test $# -ge 2 || { err "usage error: test_expect_failure msg cmd args ..."; return 1; }
  say -n "$test_msg: $test_sanename: $msg (expecting success) "
  shift
  (eval "$@" 4>&1) && {
     say -e "\n$test_msg: PASS %%% $test_sanename"
     test_str_pass="$test_str_pass $test_sanename"
     test_n_pass=test_n_pass+1; return 0;
  }
  say -e "\n$test_msg: FAIL %%% $test_sanename" 
  test_str_fail="$test_str_fail $test_sanename"
  test_n_fail=test_n_fail+1
  return 1
}

test_expect_failure () {
  local msg="$1" 
  test $# -ge 2 || { err "usage error: test_expect_failure msg cmd args ...";  return 1;}
  say -n "$test_msg: -- $msg (expecting failure) "
  shift
  (eval "$@" 4>&1) || {
    say -e "\n$test_msg: PASS %%% $test_sanename"
    test_str_pass="$test_str_pass $test_sanename"
    test_n_pass=test_n_pass+1; return 0 ;
  }
  say -e "\n$test_msg: FAIL %%% $test_sanename"
  test_str_fail="$test_str_fail $test_sanename"
  test_n_fail=test_n_fail+1
  return 1
}

test_egrep() {
  local nsecs="$1"
  local txt="$2"
  local ret
  shift 2
  test_expect_success "" \
    "s=1;
    typeset -i i=0
    while [ \$i -lt $nsecs ];do
      i=i+1
      say -n '.'
      o=\$(egrep -h \"$txt\" ${test_filename?} ) && \
        { _P=$'\n         ' debug -n \$o; s=0; break; }
      sleep 1;
    done;
    exit \$s
    " 2>/dev/null 4>$LIBTEST_OUTPUT_DIR/$USER-test-lib.err
  ret=$?
  test $ret -eq 0 && return 0
  mv ${test_filename}{,.fail}
  _P='  ' err "$test_sanename: log at ${test_filename}.fail" 
  return $ret
}

test_bg_egrep() {
  local nsecs="$1"
  local txt="$2"
  local ret
  shift 2
  test_expect_success "" \
    "set -m ; $@ > ${test_filename?} 2>&1 &
    s=1;
    typeset -i i=0
    while [ \$i -lt $nsecs ];do
      i=i+1
      say -n '.'
      kill -0 %1 || { egrep failed ${test_filename?} >&4; break; }
      o=\$(egrep \"$txt\" ${test_filename?} ) && { _P=$'\n         ' debug -n \$o; s=0; break; }
      sleep 1;
    done;
    kill %1
    wait
    exit \$s
    " 2>/dev/null 4>$LIBTEST_OUTPUT_DIR/$USER-test-lib.err
  ret=$?
  test $ret -eq 0 && return 0
  mv ${test_filename?}{,.fail}
  _P='  ' err "$test_sanename: log at ${test_filename}.fail" 
  return $ret
}
# run command in *current* shell ignoring stderr, evals args passed
quiet2() {
  #backup fd=2
  exec 5>&2
  exec 2>/dev/null
  eval "$@"
  #close auxfd
  exec 2>&5
  exec 5>&-
}
test_bg_prev(){ $@ >>${test_filename?} 2>&1 & }
test_cleanup()    { quiet2 "$TEST_CLEANUP;${@:-:};trap '' 15; pkill -g 0 2>/dev/null;trap 15;wait" ;}
test_bg_cleanup() { quiet2 "$TEST_CLEANUP;${@:-:};kill % 2>/dev/null;wait" ;}
test_set_cleanup () { TEST_CLEANUP="${*:-:}" ;}

: ${LIBTEST_OUTPUT_DIR?}
exec 3>&1
exec 4>&2

