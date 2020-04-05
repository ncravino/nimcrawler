
import random 
import illwill

type 
    WorldObject {.pure.} = enum
        Wall="▓", Player="@", Dirt=".", Enemy="X"

let H = 30
let W = 60

var world = newSeq[seq[WorldObject]](H)

for i in 0..H-1:
    world[i] = newSeq[WorldObject](W)
    for j in 0..W-1:
        world[i][j]=WorldObject.Wall

for t in 0..400:
    var i = rand(0..H-1)
    var j = rand(0..W-1)
    for l in 0..int(H/4):
        world[i][j] = WorldObject.Dirt
        var idiff = rand([-1,0,1])
        var jdiff = rand([-1,0,1])
        i += idiff
        if i >= H or i < 0:
            i -= idiff

        j += jdiff
        if j >= W or j < 0:
            j -= jdiff




proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0)


var playi : int
var playj : int

while true:
  playi = rand(0..H-1)
  playj = rand(0..W-1)
  if world[playi][playj] == WorldObject.Dirt:
        world[playi][playj] = WorldObject.Player
        break

setControlCHook(exitProc)
illwillInit()
hideCursor()
        
var tb = newTerminalBuffer(terminalWidth(),terminalHeight())


var nplayi : int
var nplayj : int

var Hc : int = H div 2.int
var Wc : int = W div 2.int

var notStart = 0

var playerColor = fgGreen

let nameY = 0
let healthY = 1
let posY = 2
let attackY = 3
let msgY = 4
let boxX = W + 1

var name = "coiso"
var health = 10

while true:
    var attack = 0
    var attacki : int
    var attackj : int
    var keypress = getKey()
    if keypress == Key.Q:
        break
    elif keypress == Key.None and notStart == 1:
        continue
    elif keypress != Key.None and notStart == 1:        
        nplayi = playi
        nplayj = playj
        case keypress:
            of Key.S:
                playi += 1
            of Key.W:
                playi -= 1
            of Key.A:
                playj -= 1
            of Key.D:
                playj += 1
            of Key.ShiftS:
                attack = 1
                attacki = playi + 1            
                attackj = playj
            of Key.ShiftW:
                attack = 1
                attacki = playi - 1            
                attackj = playj
            of Key.ShiftA:
                attack = 1
                attacki = playi             
                attackj = playj - 1
            of Key.ShiftD:
                attack = 1
                attacki = playi             
                attackj = playj + 1
            else:
                discard 
        if playi < 0 or playi >= H or playj < 0 or playj >= W or world[playi][playj] != WorldObject.Dirt:       
            playerColor = fgRed
            playi = nplayi
            playj = nplayj
            tb.setForegroundColor(playerColor)
            tb.write(boxX,msgY,"Can't move that way")
            tb.setForegroundColor(fgWhite)
        else:
            world[nplayi][nplayj] = WorldObject.Dirt
            world[playi][playj] = WorldObject.Player
            playerColor = fgGreen
            tb.clear()



    for i in 0..H-1:
       for j in 0..W-1: 
          case world[i][j]:
              of WorldObject.Dirt:
                   tb.write(j,i, $(WorldObject.Dirt))
              of WorldObject.Player: 
                   tb.setForegroundColor(playerColor)
                   tb.write(j,i,$(WorldObject.Player))
                   tb.setForegroundColor(fgWhite)
              of WorldObject.Enemy:
                  tb.write(j,i,$(WorldObject.Enemy))
              else:
                  tb.write(j,i,$(WorldObject.Wall))
                  
    if attack == 1:
        tb.setForegroundColor(fgCyan)
        var attackObj = " a Wall. The wall is winning!"
        case world[attacki][attackj]:
            of WorldObject.Dirt:
                attackObj = "! But there is nothing but dirt there"
            of WorldObject.Enemy:
                attackObj = " an hideous monster!"
            else:
                discard
        tb.write(boxX,attackY,"Player attacks" & attackObj) 
        tb.setForegroundColor(fgWhite)
        
    tb.write(boxX,nameY,"Player " & name) 
    tb.write(boxX,healthY,"Health: " & $(health)) 
    tb.write(boxX,posY,"Player at " & $(playi) & "," & $(playj)) 
    hideCursor()
    tb.display()
    notStart =  1        

tb.write(0,0,"Game Over")
tb.display()
exitProc()
