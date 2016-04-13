import sys
import random
import math
args = sys.argv

length = int(args[1])
size = int(args[2])

inputFile = open('Input.txt','w')
outputFile = open('Output.txt','w')

max_number = math.pow(10, length + 1)
min_number = math.pow(10, length)

for i in range(size):
    var1 = int(random.uniform(min_number, max_number))
    var2 = int(random.uniform(min_number, max_number))
    input = "print(" + str(var1) + "+" + str(var2) + ").\n"
    inputFile.write(input)
    output = str((var1+var2))+".\n"
    outputFile.write(output)

inputFile.close()
outputFile.close()
