function _fish_cdutils_recd --description "Re-enter the current directory"
    set -l current (pwd)
    cd $current
  end
