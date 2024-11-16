function note
    echo "date: $(date)" >> $HOME/notes.txt
    echo "$argv" >> $HOME/notes.txt
    echo "" >> $HOME/notes.txt
end

