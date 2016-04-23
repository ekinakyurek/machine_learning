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
 

for len in range(int(size/300)):
    
    if type == "trn": 
        max_number = math.pow(10, leng + 1)                                    
        min_number = math.pow(10, leng)
        
        batch = []
        
        for i in range(100):                                                                    
            var = int(random.uniform(min_number, max_number))  
            
            inputFile.write(str(var)+"\n")   #input                                          
            outputFile.write(str(var)+"\n") # output   
                                                
            SpacedinputFile.write(splitCharacter(str(var)))  #spaced input        
            SpacedOutputFile.write(splitCharacter(str(var))) #spaced output
            
            batch.append(var)   
            
        
        for j in range(100):      
                            
            var = batch[j]                                         
            inputFile.write(str(var) + str(var)+"\n") #doubled input                                       
            outputFile.write(str(var)+"\n") # output                                           
            
            SpacedinputFile.write(splitCharacter(str(var)+str(var)))   #doubled input                           
            SpacedOutputFile.write(splitCharacter(str(var)))    #output
            
        for j in range(100):                                                                    
            
            var = batch[j]                                                
            inputFile.write(str(var)[::-1]+"\n") # reversed input                                           
            outputFile.write(str(var)+"\n") # output                                          
                                
            SpacedinputFile.write(splitCharacter(str(var)[::-1])) #reversed input
            SpacedOutputFile.write(splitCharacter(str(var)))   #output
    
    
        if len%2 == 1:
            leng = leng + 1
    else:         
        for i in range(300):                                                                    
            var = int(random.uniform(min_number, max_number))
            inputFile.write(str(var)+"\n")   #input                                          
            outputFile.write(str(var)+"\n") # output   
                                                    
            SpacedinputFile.write(splitCharacter(str(var)))  #spaced input        
            SpacedOutputFile.write(splitCharacter(str(var))) #spaced output
            
inputFile.close()
SpacedinputFile.close()
outputFile.close()
SpacedOutputFile.close()
