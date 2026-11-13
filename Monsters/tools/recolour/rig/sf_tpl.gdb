set pagination off
break exit
run
set $arr = *(char**)&sprites
set $cnt = *(unsigned*)((char*)&sprites+8)
printf "SPRITES count=%u\n", $cnt
eval "dump binary memory OUTFILE %lu %lu", $arr, $arr + 12*$cnt
kill
quit
