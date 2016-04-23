import sys
import random
import math
args = sys.argv

def splitCharacter(text):
    newtext = ""
    for c in text:
        newtext = newtext + c + " "
        newtext = newtext[:-1]
        newtext = newtext + "\n"
    return newtext

leng = int(args[1])
size = int(args[2])
type = str(args[3])

if type == "trn":
    SpacedinputFile = open('SMemoTrn','w')
    inputFile = open('MemoTrn','w')   
else:
    SpacedinputFile = open('SMemoTst','w')
    inputFile = open('MemoTst','w') 

max_number = math.pow(10, leng + 1)
min_number = math.pow(10, leng)

max_len = int(size/100)
for len in range(max_len):
    max_number = math.pow(10, leng + 1)                                    
    min_number = math.pow(10, leng)
    
    for i in range(100):   
        var = int(random.uniform(min_number, max_number))
        inputFile.write(str(var)+"\n")
        inputFile.write(str(var)[::-1]+"\n") 
        SpacedinputFile.write(splitCharacter(str(var)))
        SpacedinputFile.write(splitCharacter(str(var)[::-1]))
 
    if len%100 == 1:
        leng = leng + 1

inputFile.close()
SpacedinputFile.close()
