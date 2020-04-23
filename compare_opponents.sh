#!/bin/bash

ITERS=1000

if [ $1 == "1" ]; then
time swift run TTR ./east.json 25 3000 rr 1.0 -o rvr2.csv >> rvr.out
time swift run TTR ./east.json 25 3000 rrr 1.0 -o  rvr3.csv >> rvr.out
time swift run TTR ./east.json 25 3000 rrrr 1.0 -o  rvr4.csv >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrr 1.0 -o  rvr5.csv >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrrr 1.0 -o  rvr6.csv >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrrrr 1.0 -o  rvr7.csv >> rvr.out

time swift run TTR ./east.json 25 80 brrm 0.5 $ITERS exp0.5.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 0.8 $ITERS exp0.8.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 0.9 $ITERS exp0.9.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.0 $ITERS exp1.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.1 $ITERS exp1.1.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.2 $ITERS exp1.2.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.5 $ITERS exp1.5.csv >> exp.out
time swift run TTR ./east.json 25 80 brrm 2.0 $ITERS exp2.0.csv >> exp.out

elif [ $1 == "2" ]; then
time swift run TTR ./east.json 25 3000 bb 1.0 bvb2.csv >> bvb.out
time swift run TTR ./east.json 25 3000 bbb 1.0 bvb3.csv >> bvb.out
time swift run TTR ./east.json 25 3000 bbbb 1.0 bvb4.csv >> bvb.out
time swift run TTR ./east.json 25 3000 bbbbb 1.0 bvb5.csv >> bvb.out
time swift run TTR ./east.json 25 3000 bbbbbb 1.0 bvb6.csv >> bvb.out
time swift run TTR ./east.json 25 3000 bbbbbbb 1.0 bvb7.csv >> bvb.out

time swift run TTR ./east.json 25 50 brrm 1.0 100000 fun1.0.csv >> fun.out
time swift run TTR ./east.json 25 50 brrm 0.8 100000 fun0.8.csv >> fun.out

elif [ $1 == "3" ]; then
time swift run TTR ./east.json 25 40 mm 1.0 $ITERS $ITERS mvm2.csv >> mvm.out
time swift run TTR ./east.json 25 40 mmm 1.0 $ITERS $ITERS $ITERS mvm3.csv >> mvm.out
time swift run TTR ./east.json 25 40 mmmm 1.0 $ITERS $ITERS $ITERS $ITERS mvm4.csv >> mvm.out
time swift run TTR ./east.json 25 40 mmmmm 1.0 $ITERS $ITERS $ITERS $ITERS $ITERS mvm5.csv >> mvm.out
time swift run TTR ./east.json 25 20 mmmmmm 1.0 $ITERS $ITERS $ITERS $ITERS $ITERS $ITERS mvm6.csv >> mvm.out
time swift run TTR ./east.json 25 10 mmmmmmm 1.0 $ITERS $ITERS $ITERS $ITERS $ITERS $ITERS $ITERS mvm7.csv >> mvm.out

elif [ $1 == "4" ]; then
time swift run TTR ./east.json 25 300 mrrr 1.0 $ITERS mvr1.csv >> mvr.out
time swift run TTR ./east.json 25 300 rmrr 1.0 $ITERS mvr2.csv >> mvr.out
time swift run TTR ./east.json 25 300 rrmr 1.0 $ITERS mvr3.csv >> mvr.out
time swift run TTR ./east.json 25 300 rrrm 1.0 $ITERS mvr4.csv >> mvr.out

fi
