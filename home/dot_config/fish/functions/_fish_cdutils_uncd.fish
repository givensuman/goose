function _fish_cdutils_uncd --description "Change to the previous directory and remove history entry"
  prevd > /dev/null
  set -g -e dirnext[1]
end
