#!/bin/sh
set -e

# Quote each argument for the inner shell: wrap in single quotes, escape ' as '\''
# so the -c string passes args through without space/split or quoting issues
quoted=""
for a in "$@"; do
  safe=$(echo "$a" | /usr/local/bin/sed "s/'/'\\\\''/g")
  quoted="$quoted '$safe'"
done

# Execute cyanrip inside a PTY; line-buffer so output appears in real time; normalize CRLF/LF; show progress at 0%, 5%, 10%, ...
/usr/local/bin/stdbuf -oL /usr/local/bin/script -q -c "/usr/local/bin/cyanrip $quoted" /dev/null \
  | /usr/local/bin/stdbuf -oL /usr/local/bin/sed -e 's/\r$//' -e 's/\r/\n/g' \
  | while IFS= read -r line; do
  case "$line" in
    *progress\ -\ [0-9]*.*%*)
      p=$(echo "$line" | /usr/local/bin/stdbuf -oL /usr/local/bin/sed -n 's/.*progress - \([0-9]*\)\.[0-9]*%.*/\1/p')
      if [ -n "$p" ]; then
        bucket=$(( (p / 5) * 5 ))
        : "${last:=-1}"
        if [ "$bucket" -gt "$last" ] && [ $((bucket % 5)) -eq 0 ]; then
          echo "$line"
          last=$bucket
        fi
      else
        echo "$line"
      fi
      ;;
    *)
      echo "$line"
      last=-1
      ;;
  esac
done
