import sys
import random
import math
args = sys.argv

length = int(args[1])
size = int(args[2])
type = str(args[3])

if type == "trn":
    SpacedinputFile = open('SInTrn','w')
    SpacedoutputFile = open('SOutTrn','w')
    inputFile = open('InTrn','w')   
    outputFile = open('OutTrn','w')
else:
    SpacedinputFile = open('SInTst','w')
    SpacedoutputFile = open('SOutTst','w')
    inputFile = open('InTst','w')   
    outputFile = open('OutTst','w')

max_number = math.pow(10, length + 1)
min_number = math.pow(10, length)

def splitCharacter(text):
    newtext = ""
    for c in text:
        newtext = newtext + c + " "
    newtext = newtext[:-1]
    newtext = newtext + "\n"
    return newtext
        
for i in range(size):
    var1 = int(random.uniform(min_number, max_number))
    var2 = int(random.uniform(min_number, max_number))
    input = "print(" + str(var1) + "+" + str(var2) + ")"
    inputFile.write(input+"\n")
    SpacedinputFile.write(splitCharacter(input))
    output = str((var1+var2))
    outputFile.write(output+"\n")
    SpacedoutputFile.write(splitCharacter(output))

inputFile.close()
outputFile.close()
SpacedinputFile.close()
SpacedoutputFile.close()