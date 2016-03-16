" Make ZZ behave
function! BehaveZZ()
    " Get the number of *listed* buffers.
    let highbuf = bufnr("$")
    let buflist = []
    let i = 1
    while (i <= highbuf)
        "Skip unlisted buffers.
        if (bufexists(i) != 0 && buflisted(i))
            call add(buflist, i)
        endif
        let i = i + 1
    endwhile
    let bufcount = len(buflist)
    if (bufcount == 1)
        if (bufname("%") == "")
            " This buffer is unnamed (has no associated file).
            if (&modified)
                " Give option to save modifications.
                let choice = input("Lose modifications? [Enter=yes]: ")
                if (choice == "")
                    set nomodified
                else
                    echo "ZZ action aborted..."
                    return
                endif
            else
                " The buffer has no modifications. Just do default ZZ.
                execute "x"
            endif
        else
            " There is only one listed buffer and it is named. In this case, 
            " the standard ZZ works just fine, so do that.
            execute "x"
        endif
    elseif (getbufvar(bufnr("%"), "&buftype") != "")
        " This buffer is a "special" buffer.
        execute "bdelete"
    elseif (bufname("%") == "")
        " This buffer is unnamed (has no associated file).
        if (&modified)
            " Give option to save modifications.
            let choice = input("Lose modifications? [Enter=yes]: ")
            if (choice == "")
                set nomodified
            else
                echo "ZZ action aborted..."
                return
            endif
        endif
        if (winnr("$") > 1)
            " There are multiple windows open. Just do a normal ZZ.
            execute "x"
        else
            execute "buffer! " . bufnr("#")
        endif
    else
        " This is a named buffer. 
        if (&modified)
            execute "write"
        endif
        if (winnr("$") > 1)
            " There are multiple windows. Just do normal ZZ.
            execute "x"
        else
            " There is only one window, but multiple listed buffers.
            let curbuf = bufnr("%")
            " If we have a 'last visited' buffer, go there. Else bnext.
            if (bufnr("#") != -1)
                execute "buffer! " . bufnr("#")
            else
                execute "bnext"
            endif
            execute "bdelete" . curbuf
        endif
    endif
endfunction
