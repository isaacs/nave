alias _type=$(which type)
type () {
  if [ "$1" = "arch" ]; then
    return 1
  else
    _type "$@"
    return $?
  fi
}
