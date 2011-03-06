#!/bin/bash

typeset -i test_num=0 # increments w/each test_define
typeset test_msg	# prefix: "Test nr#"  for msgs
typeset test_name	# test name given	
typeset test_sanename	# test name with all whitespace (and alike) replaced by '_'

TEST_CLEANUP=":"

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
	test_name="$*"
	test_sanename="$(echo -n $test_name| tr -c '[A-Za-z0-9._]' _ )"
	test_num=test_num+1
	test_msg="Test $test_num"
	test_bg_cleanup 
}
test_expect_success () {
	local msg="$1" 
	test $# -ge 2 || { err "usage error: test_expect_failure msg cmd args ..."; return 1; }
	say -n "$test_msg: $test_sanename: $msg (expecting success) "
	shift
	(eval "$@" 4>&1) && { say -e "\n$test_msg: PASS %%% $test_sanename" ;  return 0 ; }
	say -e "\n$test_msg: FAIL %%% $test_sanename" 
	return 1
}

test_expect_failure () {
	local msg="$1" 
	test $# -ge 2 || { err "usage error: test_expect_failure msg cmd args ...";  return 1;}
	say -n "$test_msg: -- $msg (expecting failure) "
	shift
	(eval "$@") && { say -e "\n$test_msg: FAIL %%% $test_sanename" >&3 ;  return 0 ; }
	say -e "\n$test_msg: OK %%% $test_sanename"
	return 1
}

test_bg_egrep() {
	local nsecs="$1"
	local txt="$2"
	local ret
	shift 2
	test_expect_success "" \
		"set -m ; $@ &> $t/out-$test_sanename &
		s=1;
		for i in \$(seq 1 $nsecs);do 
			say -n '.'
			kill -0 %1 || { egrep failed $t/out-$test_sanename >&4; break; }
			o=\$(egrep \"$txt\" $t/out-$test_sanename ) && { _P=$'\n  ' debug -n \$o; s=0; break; }
			sleep 1;
		done;
		kill %1
		wait
		exit \$s
		" 2>/dev/null 4>$t/err
	ret=$?
	test $ret -eq 0 && return 0
	mv --backup=t $t/out-$test_sanename{,.fail}
	_P='  ' err "$test_sanename: log at $t/out-$test_sanename.fail" 
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
test_bg_prev(){ local out=$t/out-$test_sanename-prev; $@ >& $out & }
test_bg_cleanup() { quiet2 "$TEST_CLEANUP;${@:-:};kill % 2>/dev/null;wait" ;}
test_set_cleanup () { TEST_CLEANUP="${*:-:}" ;}

: ${LIBTEST_OUTPUT_DIR?}
exec 3>&1
exec 4>&2

