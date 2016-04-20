import sys
import random
import math
args = sys.argv

length = int(args[1])
size = int(args[2])

inputFile = open('InputT.txt','w')
outputFile = open('OutputT.txt','w')

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
    inputFile.write(splitCharacter(input))
    output = str((var1+var2))
    outputFile.write(splitCharacter(input))

inputFile.close()
outputFile.close()
