erl -pa ebin -noinput +B -eval "ok = item:start(), item:insert_from_file(\"$1\"), mnesia:stop(), halt(0)."
