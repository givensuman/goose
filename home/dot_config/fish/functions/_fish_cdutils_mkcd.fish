function _fish_cdutils_mkcd --description "Create a new directory and change into it"
    if test (count $argv) -eq 0; or test (count $argv) -gt 1
        echo "Usage: mkcd <directory_name>"
        return 1
    end

    set -l dir $argv[1]

    mkdir -p $dir
    cd $dir
  end
