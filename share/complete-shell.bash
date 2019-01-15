# shellcheck shell=bash

: "${COMPLETE_SHELL_PATH:=$HOME/.complete-shell}"

all-compgens() {
  while IFS='' read -r line; do
    [[ $line =~ ^\" ]] && continue
    echo "$line" | cut -f1
  done < "$COMPLETE_SHELL_ROOT/share/search-index.tsv"
}

installed() (
  shopt -s nullglob
  cd "$COMPLETE_SHELL_COMP" || return 0
  set -- *.comp
  printf "%s\n" "${@%.comp}"
)

enabled() (
  shopt -s nullglob
  cd "$COMPLETE_SHELL_BASH_DIR" || return 0
  set -- !(complete-shell).bash
  printf "%s\n" "${@%.bash}"
)

disabled() (
  shopt -s nullglob
  cd "$COMPLETE_SHELL_COMP" || return 0
  for comp in !(complete-shell).comp; do
    comp=${comp%.comp}
    if [[ ! -f $COMPLETE_SHELL_BASH_DIR/$comp.bash ]]; then
      echo "$comp"
    fi
  done
)
