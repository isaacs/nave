_TESTING_NAVE_NO_MAIN=1 . nave.sh

enquote_all "a b" "c" ""
enquote_all "q't" '"q"' "'s'"
enquote_all "'''''"
enquote_all
