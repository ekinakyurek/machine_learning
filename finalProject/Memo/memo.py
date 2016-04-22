import sys
import random
import math
args = sys.argv

size = int(args[2])
type = str(args[3])

if type == "trn":
    SpacedinputFile = open('SMemoTrn','w')
    inputFile = open('MemoTrn','w')   
else:
    SpacedinputFile = open('SMemoTst','w')
    inputFile = open('MemoTst','w') 

def splitCharacter(text):
    newtext = ""
    for c in text:
        newtext = newtext + c + " "
    newtext = newtext[:-1]
    newtext = newtext + "\n"
    return newtext
        
for i in range(size):
    length = int(random.uniform(5,35))
    max_number = math.pow(10, length + 1)                                               
    min_number = math.pow(10, length)      
    var = int(random.uniform(min_number, max_number))
    inputFile.write(str(var)+"\n")
    SpacedinputFile.write(splitCharacter(str(var)))

inputFile.close()
SpacedinputFile.close()
