#!/bin/bash

if [ $1 == "1" ]; then
time swift run TTR ./east.json 25 3000 rr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrrr 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 rrrrrrr 1.0 >> rvr.out

elif [ $1 == "2" ]; then
time swift run TTR ./east.json 25 3000 bb 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 bbb 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 bbbb 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 bbbbb 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 bbbbbb 1.0 >> rvr.out
time swift run TTR ./east.json 25 3000 bbbbbbb 1.0 >> rvr.out

elif [ $1 == "3" ]; then
time swift run TTR ./east.json 25 300 mm 1.0 2000 >> rvr.out
time swift run TTR ./east.json 25 300 mmm 1.0 2000 >> rvr.out
time swift run TTR ./east.json 25 300 mmmm 1.0 2000 >> rvr.out
time swift run TTR ./east.json 25 300 mmmmm 1.0 2000 >> rvr.out
time swift run TTR ./east.json 25 300 mmmmmm 1.0 2000 >> rvr.out
time swift run TTR ./east.json 25 300 mmmmmmm 1.0 2000 >> rvr.out
fi