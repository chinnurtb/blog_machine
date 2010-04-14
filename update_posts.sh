cd $(dirname $0)
erl -pa ebin -noinput +B -eval "ok = item:start(), item:insert_from_dir(\"../posts/\"), mnesia:stop(), halt(0)."
service blog restart
