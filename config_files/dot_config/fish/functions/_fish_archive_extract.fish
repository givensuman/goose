# Extract various archive formats
# Arguments: $argv - archive file(s) to extract
# Returns: 0 on success, 1 on error
function _fish_archive_extract
    if test (count $argv) -lt 1
        echo "Usage: extract <archive_file>"
        return 1
    end

    set -l failure false

    # Validate all files exist
    for file in $argv
        if not test -f $archive
            echo "File not found: $archive"
            set failure true
        end
    end

    if $failure
        return 1
    end

    # Detect tar command
    set -l tar
    if command -q gtar
        set tar gtar
    else
        set tar tar
    end

    # Extract each archive based on file extension
    for file in $argv
        switch $file
            case '*.tar'
                $tar xvf "$file"

            case '*.tar.gz' '*.tgz'
                $tar xvzf "$file"

            case '*.tar.bz2' '*.tar.bz' '*.tbz' '*.tbz2'
                $tar xvjf "$file"

            case '*.tar.xz' '*.txz'
                $tar xvJf "$file"

            case '*.tar.Z' '*.taz'
                $tar xvZf "$file"

            case '*.tar.zst' '*.tzst'
                $tar --zstd -xvf "$file"

            case '*.tar.lzma' '*.tar.zma' '*.tlz'
                $tar --lzma -xvf "$file"

            case '*.tar.lrz'
                lrzuntar "$file"

            case '*.tar.lz'
                $tar --lzip -xvf "$file"

            case '*.tar.lz4'
                $tar --use-compress-program=lz4 -xvf "$file"

            case '*.tar.lzo'
                $tar --lzop -xvf "$file"

            case '*.7z' '*.iso'
                7z x "$file"

            case '*.gz'
                gunzip --keep "$file"

            case '*.bz2' '*.bz'
                bunzip2 --keep "$file"

            case '*.xz'
                unxz --keep "$file"

            case '*.lrz'
                lrunzip "$file"

            case '*.lz4'
                unlz4 "$file" (string replace --regex '.lz4$' '' "$file")

            case '*.lzma'
                unlzma --keep "$file"

            case '*.zip' '*.xpi' '*.jar'
                unzip "$file"

            case '*.Z'
                uncompress -k "$file"

            case '*.zst'
                unzstd --keep "$file"

            case '*.zz'
                unpigz --keep "$file"

            case '*'
                echo "Unsupported archive format: $file"
                set failure true
        end

        if test $status -ne 0
            echo "Failed to extract file: $file"
            set failure true
        end
    end

    if $failure
        return 1
    end
end

