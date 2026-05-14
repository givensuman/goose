# Display brew leaves with dependencies and casks
function _fish_brew_bleaves
    set -l formulae "$(brew leaves | xargs brew deps --installed --for-each)"
    set -l casks "$(brew list --cask)"

    echo \=\=\> (set_color --bold red)Forumlae
    echo (set_color normal)$formulae | sed "s/^\(.*\):\(.*\)\$/\1$(set_color blue)\2$(set_color normal)/"
    echo \n\=\=\> (set_color --bold red)Casks
    echo (set_color normal)$casks
end
