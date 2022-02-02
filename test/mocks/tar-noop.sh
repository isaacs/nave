# just a no-op so tests don't take a long time if they don't
# care about the actual unpacked results.
tar () {
  echo "no-op mock: tar $@" >&2
  cat >/dev/null
}
