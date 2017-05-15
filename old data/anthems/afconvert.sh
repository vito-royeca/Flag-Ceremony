for i in *.mp3; do afconvert -v -f caff -d LEI16@44100 $i ${i%.mp3}.caf; done
