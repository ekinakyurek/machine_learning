import sys
import random
import math
import os
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
    if os.path.exists("SInTrn"):
        os.remove("SInTrn")
    if os.path.exists("SOutTrn"):
        os.remove("SOutTrn")
    if os.path.exists("InTrn"):
        os.remove("InTrn")
    if os.path.exists("InTrn"):
        os.remove("OutTrn")
                                                                             
    SpacedinputFile = open('SInTrn','w')                                                  
    SpacedOutputFile = open('SOutTrn', 'w')                                               
    inputFile = open('InTrn','w')                                                         
    outputFile = open('OutTrn','w')                                                       
else:                 
    
    if os.path.exists("SInTst"):
        os.remove("SInTst")
    if os.path.exists("SOutTst"):
        os.remove("SOutTst")
    if os.path.exists("InTst"):
        os.remove("InTst")
    if os.path.exists("InTst"):
        os.remove("OutTst")
                                                                        
    SpacedinputFile = open('SInTst','w')                                                  
    SpacedOutputFile = open('SOutTst','w')                                                
    inputFile = open('InTst','w')                                                         
    outputFile = open('OutTst','w')  

max_number = math.pow(10, leng + 1)
min_number = math.pow(10, leng)
 

for len in range(int(size/200)):
    if type == "trn": 
        max_number = math.pow(10, leng + 1)                                    
        min_number = math.pow(10, leng)
        
        batch = []
        var1 = 0
        var2 = 0
        for i in range(100):                                                                     
    	    if i%2==0:       
                var1 = int(random.uniform(min_number, max_number))  
                var2 = int(random.uniform(min_number, max_number)) 
            else:
                length = int(random.uniform(4,12))
                var1= int(random.uniform(math.pow(10, length),math.pow(10, length+1)))
                var2= int(random.uniform(math.pow(10, length),math.pow(10, length+1)))
            inputFile.write(str(var1)+"+"+str(var2)+"\n")   #input                                          
            outputFile.write(str(var1+var2)+"\n") # output   
                                                
            SpacedinputFile.write(splitCharacter(str(var1)+"+"+str(var2)))  #spaced input        
            SpacedOutputFile.write(splitCharacter(str(var1+var2))) #spaced output
            batch.append((var1,var2))

        for j in range(100):      
            var1,var2 = batch[j]                                                         
            inputFile.write(str(var2) + "+" +str(var1)+ "\n") #doubled input                                       
            outputFile.write(str(var1+var2)+"\n") # output                                           
            
            SpacedinputFile.write(splitCharacter(str(var2) + "+" +str(var1)))   #doubled input                           
            SpacedOutputFile.write(splitCharacter(str(var1+var2)))    #output
            
     #   for j in range(100):                                                                              
      #      inputFile.write((str(var1)+"+"+str(var2))[::-1]+"\n") # reversed input                                           
       #     outputFile.write(str(var1+var2)+"\n") # output                                          
                                
        #    SpacedinputFile.write(splitCharacter((str(var1)+"+"+str(var2))[::-1])) #reversed input
         #   SpacedOutputFile.write(splitCharacter(str(var1+var2)))   #output
    
    
        if len%200== 1:
            leng = leng + 1
    else:         
        for i in range(100):
            var1 = int(random.uniform(min_number, max_number))
            var2 = int(random.uniform(min_number, max_number))
            inputFile.write(str(var1)+"+"+str(var2)+"\n")   #input                                          
            outputFile.write(str(var1+var2)+"\n") # output   

            inputFile.write(str(var2) + "+" +str(var1) +"\n")
            outputFile.write(str(var1+var2))
            SpacedinputFile.write(splitCharacter(str(var1)+"+"+str(var2)))  #spaced input
            
            SpacedOutputFile.write(splitCharacter(str(var1+var2))) #spaced output
            SpacedinputFile.write(splitCharacter(str(var2)+"+"+str(var1)))
            SpacedOutputFile.write(splitCharacter(str(var1+var2)))
            
inputFile.close()
SpacedinputFile.close()
outputFile.close()
SpacedOutputFile.close()
