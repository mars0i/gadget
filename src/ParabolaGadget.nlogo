breed [path-points path-point]
path-points-own [my-x my-y]

globals [
  max-coord   ; like max-pxcor, max-pycor, but smaller so there's a margin
  min-coord   ; mutatis mutandis
  parabolic-scaling-factor ; make parabola size correct
  curve-shape ; for the line and parabola
  curve-size  ; ditoo
  path-current-point-shape  ; for the dynamic path
  path-past-point-shape
  path-size   ; ditto
  path-color  ; ditto
  path-turtle ; will hold the turtle that draws the path
  past-xs ; list of past points chosen
  z ; See Myrovld chapter 4
  past-zs ; list of past points chosen
  z-pointer-turtle ; hold the pointer for the z location
]

to init-vars
  set max-coord max-pxcor - 7 ; increment should be adjusted to fit world dimensions
  set min-coord max-coord * -1
  set parabolic-scaling-factor max-coord / 2 ; i.e. divide width by 4, i.e. 2^2
  set curve-shape "circle"
  set curve-size 2
  set path-current-point-shape "circle"
  set path-past-point-shape "circle 2"
  set path-size 9
  set path-color white
  ;set past-xs [] ; now set in body of setup
  set z 0
  set past-zs [] ; ignore initial value
end

to setup
  clear-all
  init-vars
  let scaled-initial-x (coord-to-world-coord initial-x)
  set past-xs (list scaled-initial-x)
  make-midpoint-divider
  make-line
  make-parabola
  ;; make the point turtle:
  ask (patch scaled-initial-x (linear scaled-initial-x))
     [sprout-path-points 1 [set path-turtle self
                            set size path-size
                            set shape path-current-point-shape
                            set color path-color]]
  ;; make the z pointer turtle:
  create-turtles 1 [set z-pointer-turtle self
                    set color orange
                    set size 15
                    set ycor min-pycor
                    set xcor coord-to-world-coord z
                    set heading 0]
  reset-ticks
end

to go
  if go-until > 0 and ticks >= go-until [stop]
  tick
  if show-past-points [ask path-turtle [hatch 1 [set shape path-past-point-shape]]]
  ask path-turtle [set z ifelse-value (xcor <= 0) [z / 2] [0.5 + (z / 2)]
                   ask z-pointer-turtle [set xcor (coord-to-world-coord z)]
                   if-else show-path [pen-down] [pen-up]
                   setxy xcor (parabolic xcor)
                   setxy (linear ycor) ycor]
  set past-xs (fput current-x past-xs)
  set past-zs (fput z past-zs)
end

to-report coord-to-world-coord [n]
  report min-coord + (n * 2 * max-coord)
end

to-report world-coord-to-coord [n]
  report (n / (2 * max-coord)) + 0.5 ; assume world is symmetrical: min = -max
end

;; called from gui; should be arg-less
to-report current-x
  let x 0
  ask path-turtle [set x xcor]
  report world-coord-to-coord x
end

to make-midpoint-divider
  let i min-coord
  while [i <= max-coord]
    [ask patch 0 i [display-point-at-patch blue]
    set i (i + 8)]
end

;; simpler but slowed by speed slider: ask patches with [pxcor = (linear pycor) and in-bounds] [display-point-at-patch red]
to make-line
  let i min-coord
  while [i <= max-coord]
    [ask patch i (linear i) [display-point-at-patch red]
     set i (i + 1)]
end

to make-parabola
  let i min-coord
  while [i <= max-coord]
    [ask patch i (parabolic i) [display-point-at-patch green]
     set i (i + 1)]
end

to-report in-bounds
  report pycor >= min-coord and pycor <= max-coord
         and
         pycor >= min-coord and pycor <= max-coord
end

to-report parabolic [x]
  report max-coord - ((x ^ 2) / parabolic-scaling-factor)
end

;; kinda silly, but allows substituation with another function later
to-report linear [x]
  report x
end

to-report binary-z
  ifelse ticks = 0  ; kludge for pre-setup display
    [report ""] ; ditto
    [report word "0." (reduce word (to-binary-list z))] ; the real thing
end

;; assumes x is in [0,1]
;; new non-recursive version
to-report to-binary-list [x]
  if x = 0 [report [0]]
  let bin-list []
  let half-power 0.5
  let x' x
  while [x' > 0]
  [
    let x-rem (x' - half-power)
    if x-rem = 0 [report (lput 1 bin-list)] ; NOTE this is the only return location from the loop
    set half-power (half-power / 2)
    ifelse x-rem > 0
      [set x' x-rem
       set bin-list (lput 1 bin-list)]
      [set bin-list (lput 0 bin-list)]
  ]
end

;; TODO DELETE ME later
;; old recursive version (easier to understand, but can't assume tail code elimination)
to-report to-binary-list-recursive [x]
  report to-binary-aux x 0.5 []
end
to-report to-binary-aux [x half-power bin-list]
  let x-rem  x - half-power
  if x-rem = 0 [report (lput 1 bin-list)]
  ifelse x-rem > 0
    [report (to-binary-aux x-rem (half-power / 2) (lput 1 bin-list))]
    [report (to-binary-aux x (half-power / 2) (lput 0 bin-list))]
end

to display-point-at-patch [point-color]
  sprout 1 [set size curve-size
            set shape curve-shape
            set color point-color]
end
@#$#@#$#@
GRAPHICS-WINDOW
395
10
818
434
-1
-1
1.0
1
10
1
1
1
0
0
0
1
-207
207
-207
207
0
0
1
ticks
30.0

BUTTON
10
10
65
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
80
180
113
initial-x
initial-x
0
1
0.042
0.001
1
NIL
HORIZONTAL

BUTTON
66
10
128
43
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
129
10
184
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
8
46
180
79
go-until
go-until
0
200
0.0
1
1
NIL
HORIZONTAL

SWITCH
7
179
180
212
show-path
show-path
0
1
-1000

MONITOR
5
255
180
300
x
current-x
17
1
11

SWITCH
7
216
180
249
show-past-points
show-past-points
1
1
-1000

PLOT
190
10
390
160
x distribution
NIL
NIL
0.0
1.0
0.0
5.0
true
false
"set-histogram-num-bars 50" ""
PENS
"default" 1.0 0 -16777216 true "set-plot-pen-mode 1" "histogram past-xs"

INPUTBOX
7
116
181
176
initial-x
0.042
1
0
Number

MONITOR
5
305
180
350
z
z
17
1
11

MONITOR
0
355
390
396
NIL
binary-z
17
1
10

PLOT
190
180
390
330
z distribution
NIL
NIL
0.0
1.0
0.0
10.0
true
false
"set-histogram-num-bars 50" ""
PENS
"default" 1.0 1 -16777216 true "set-plot-pen-mode 1" "histogram past-zs"

@#$#@#$#@
## WHAT IS IT?

A version of the parabola gadget that Wayne Myrvold describes in *Beyond Chance and Credence* (q.v.)

## HOW IT WORKS

Successively draws line segments from the line to the parabola, to the line, to ....

## HOW TO USE IT

Use the "initial-x" slider or text box to choose an initial x value at which the path will begin.  Then click the "setup" button.  This will draw the line and parabola, and will put a white dot on the line at that x coordinate.  (The slider is convenient, but in the non-web version of the program, it restricts initia-x to the values it's set up to allow, whereas the text box allows entering any value.  In the web version, you can do that with the slider tool as well.)

The "run-once" button will draw a path from the current point on the line to the corresponding point on the parabola, or vice versa.

The "run" button will continue the process forever, or if the "run-until" slider is set to a value other than zero, until that number of steps have been completed.  Note that after a while, the lines will overlap.  At that point it's best to click the "run" button again to stop the process.

You can turn on/off the display of path lines or the display of past points using the "show-path" and "show-past-points" switches.

## THINGS TO NOTICE

The number of steps is listed at the top as "ticks".

The current x coordinate (and therefore y coordinate) is listed in the "current-x" box.  A histogram of past x coordinates is given in the "x distribution" plot.

The little orange point at the bottom of the main area shows the value of z variable.  This is > 0.5 if the *previous* x value was <= 0.5.  The precise value of z is such that if it is displayed in binary, the first digit after the "decimal" point is 0 if the previous value of x was <= 0.5, and 1 if x was > 0.5.  Note that initial steps with x <= 0 give values for z of 0.0, 0.00, 0.000, etc., so they will appear the same, and in fact z will have the value 0.1 after x first has a value > 0.5, no matter how many steps precede this step.  (This representation will break down as the number of timesteps gets large, however, because of NetLogo's floating point number representation.)  

See section 4.4 of Myrvold's MS for further explanation.  Note that the code in the model implements the behavior described in footnote 3 on page 94 in the 12/2017 MS, rather than following the algorithm described on pages 93 and 103.

The dotted blue line indicates the midpoint--it is at 0.5.

## THINGS TO TRY

Try setting initial-x to different values.

## CREDITS AND REFERENCES

NetLogo model by Marshall Abrams (c) 2018 (GPL 3.0). 

An implementation of a mathematical device described in:

Wayne Myrvold, *Beyond Chance and Credence*, MS December 10, 2017.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
