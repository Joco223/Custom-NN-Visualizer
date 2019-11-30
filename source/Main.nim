import csfml
import json
import math

const width = 900
const height = 900

var window = newRenderWindow(videoMode(width, height), "NN Visualizer", WindowStyle.Titlebar|WindowStyle.Close, context_settings(antialiasing=8))

let nn = parseFile("test_networks/fit[69]gen[10].json")
let neuronCount = nn.len()-1
let angle = 360/neuronCount

var positions = newSeq[Vector2f]()
var connectionPositions = newSeq[Vector2f]()
var connectionsInput = newSeq[seq[int]]()
var connectionLinesBasic = newSeq[VertexArray]()
var connectionLinesStrength = newSeq[VertexArray]()

var currentAngle:float = 0
for i in countup(0, neuronCount):
  let posX:float = round(cos(degToRad(currentAngle)) * (height/2 - 15) - 10 + width/2)
  let posy:float = round(sin(degToRad(currentAngle)) * (height/2 - 15) - 10 + height/2)

  let posX2:float = round(cos(degToRad(currentAngle)) * (height/2 - 25) - 10 + width/2)
  let posy2:float = round(sin(degToRad(currentAngle)) * (height/2 - 25) - 10 + height/2)

  currentAngle += angle
  positions.add(vec2(posX, posY))
  connectionPositions.add(vec2(posX2, posY2))

for i in countup(0, nn.len()-1):
  var neuronInputConnections = newSeq[int]()
  let outputs = nn["neuron" & $i]["inputNeurons"]
  for i in countup(0, outputs.len()-1):
    neuronInputConnections.add(outputs[i].getInt())
  connectionsInput.add(neuronInputConnections)

var neuronCircle = newCircleShape(10)
neuronCircle.position = vec2(0, 0)
neuronCircle.fillColor = color(200, 200, 200, 255)

for i in countup(0, connectionPositions.len()-1):
  for connection in connectionsInput[i]:
    var currentPosition = connectionPositions[i] + vec2(10, 10)
    var targetPosition = connectionPositions[connection] + vec2(10, 10)
    var vert1: Vertex
    vert1.color = color(100, 100, 255, 255)
    vert1.position = currentPosition

    var vert2: Vertex
    vert2.color = color(100, 255, 100, 255)
    vert2.position = targetPosition

    var connectionArray = newVertexArray(PrimitiveType.Lines)
    connectionArray.append(vert1)
    connectionArray.append(vert2)
    connectionLinesBasic.add(connectionArray)

for i in countup(0, connectionPositions.len()-1):
  for j in countup(0, nn["neuron" & $i]["outputIndexes"].len()-1):
    var currentPosition = connectionPositions[i] + vec2(10, 10)
    var targetPosition = connectionPositions[nn["neuron" & $i]["outputIndexes"][j][0].getInt()] + vec2(10, 10)

    var averageStrength: float = 0
    for change in nn["neuron" & $i]["inputAdjustements"][j]:
      averageStrength += change.getFloat()
    
    averageStrength /= (float)nn["neuron" & $i]["inputAdjustements"][j].len()
    let newAlpha:int = abs((int)(255 * averageStrength))

    var vert1: Vertex
    vert1.color = color(255, 255, 255, newAlpha)
    vert1.position = currentPosition

    var vert2: Vertex
    vert2.color = color(255, 255, 255, newAlpha)
    vert2.position = targetPosition

    var connectionArray = newVertexArray(PrimitiveType.Lines)
    connectionArray.append(vert1)
    connectionArray.append(vert2)
    connectionLinesStrength.add(connectionArray)

while window.open:
  var event: Event

  while window.pollEvent event:
    if event.kind == EventType.Closed:
      window.close()
      
  window.clear(color(50, 50, 50, 255))

  for line in connectionLinesBasic:
    window.draw(line)

  for i in countup(0, neuronCount):
    neuronCircle.position = positions[i]
    if nn["neuron" & $i]["finalNeuron"].getBool():
      neuronCircle.fillColor = color(100, 100, 255, 255)
    elif nn["neuron" & $i]["inputNeuron"].getBool():
      neuronCircle.fillColor = color(100, 255, 100, 255)
    else:
      neuronCircle.fillColor = color(200, 200, 200, 255)
    window.draw(neuronCircle)

  window.display()