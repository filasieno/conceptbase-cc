set terminal png color
set output "/home/cbase/public_html/stat-images/SCRIPT.png"
set data style linespoints
set xlabel "Date"
set ylabel "Time"
set xdata time
set format x "%d.%m.%y\n"
set function style linespoints
plot '/home/cbase/crontabs/servertest/log/history/SCRIPT' using 1:($2/2) t 'i86pc/2' lt 1 pt 1, \
     '/home/cbase/crontabs/servertest/log/history/SCRIPT' using 1:3 t 'linux' lt 2 pt 2, \
     '/home/cbase/crontabs/servertest/log/history/SCRIPT' using 1:4 t 'linux64' lt 5 pt 5, \
     '/home/cbase/crontabs/servertest/log/history/SCRIPT' using 1:($5/10) t 'sun4/10' lt 3 pt 3, \
     '/home/cbase/crontabs/servertest/log/history/SCRIPT' using 1:6 t 'windows' lt 4 pt 4, \
     '/home/cbase/crontabs/servertest/log/history/SCRIPT' using 1:($7/3) t 'mac/3' lt 1 pt 3 
