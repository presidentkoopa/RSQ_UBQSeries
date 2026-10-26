set pagination off
set breakpoint pending on
break QzDoom_Vibrate(float, int, float)
commands
silent
printf "T_VIBRATE dur=%.0f chan=%d amp=%.2f\n", $xmm0.v4_float[0], $edi, $xmm1.v4_float[0]
bt 4
continue
end
run
