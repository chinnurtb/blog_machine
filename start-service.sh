#!/bin/sh
cd `dirname $0`
erl -noshell -detached -pa $PWD/ebin $PWD/deps/*/ebin $PWD/deps/*/deps/*/ebin -boot start_sasl -s blog
