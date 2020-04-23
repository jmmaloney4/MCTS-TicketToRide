#!/bin/bash

ITERS=1000

if [ $1 == "1" ]; then
time swift run TTR ./east.json 25 3000 rr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrrrr 1.0 >> rvr.out

time swift run TTR ./east.json 25 80 brrm 0.5 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 0.8 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 0.9 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.0 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.1 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.2 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 1.5 $ITERS >> exp.out
time swift run TTR ./east.json 25 80 brrm 2.0 $ITERS >> exp.out

elif [ $1 == "2" ]; then
time swift run TTR ./east.json 25 3000 bb 1.0 >> bvb.out
time swift run TTR ./east.json 25 3000 bbb 1.0 >> bvb.out
time swift run TTR ./east.json 25 3000 bbbb 1.0 >> bvb.out
time swift run TTR ./east.json 25 3000 bbbbb 1.0 >> bvb.out
time swift run TTR ./east.json 25 3000 bbbbbb 1.0 >> bvb.out
time swift run TTR ./east.json 25 3000 bbbbbbb 1.0 >> bvb.out

time swift run TTR ./east.json 25 50 brrm 100000 1.0 >> fun.out
time swift run TTR ./east.json 25 50 brrm 100000 0.8 >> fun.out

elif [ $1 == "3" ]; then
time swift run TTR ./east.json 25 40 mm 1.0 $ITERS $ITERS >> mvm.out
time swift run TTR ./east.json 25 40 mmm 1.0 $ITERS $ITERS $ITERS >> mvm.out
time swift run TTR ./east.json 25 40 mmmm 1.0 $ITERS $ITERS $ITERS $ITERS >> mvm.out
time swift run TTR ./east.json 25 40 mmmmm 1.0 $ITERS $ITERS $ITERS $ITERS $ITERS >> mvm.out
time swift run TTR ./east.json 25 20 mmmmmm 1.0 $ITERS $ITERS $ITERS $ITERS $ITERS $ITERS >> mvm.out
time swift run TTR ./east.json 25 10 mmmmmmm 1.0 $ITERS $ITERS $ITERS $ITERS $ITERS $ITERS $ITERS >> mvm.out

elif [ $1 == "4" ]; then
time swift run TTR ./east.json 25 300 mrrr 1.0 $ITERS >> mvr.out
time swift run TTR ./east.json 25 300 rmrr 1.0 $ITERS >> mvr.out
time swift run TTR ./east.json 25 300 rrmr 1.0 $ITERS >> mvr.out
time swift run TTR ./east.json 25 300 rrrm 1.0 $ITERS >> mvr.out

fi
