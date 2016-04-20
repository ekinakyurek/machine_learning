global dataX = [];
global dataY = [];
global dataMask = [];
global inPad;
global outPad;
global inputEndMark;
global outputEndMark;

global inDict =  Dict{Any,Int}();
global outDict = Dict{Any,Int}();

function readData(input,output,inputDict,outputDict; batchsize = 100, dataSize=1000)
  inputEndMark,outputEndMark, inPad, outPad = SetDictionaries(inputDict,outputDict)
  infile = open(input)
  outfile = open(output)
  for i = 1:floor(dataSize/batchsize)
   inputStr = []
   outputStr = []
   for j=1:batchsize
    push!(inputStr,rstrip(readline(infile)))
    push!(outputStr,rstrip(readline(outfile)))
   end

   max_input = findMax(inputStr)
   max_output = findMax(outputStr)

   inBatch = zeros(length(inDict),max_input+2+max_output,batchsize)
   outBatch = zeros(length(outDict),max_input+2+max_output,batchsize)
   mask  = ones(Cuchar,max_input+2+max_output,batchsize)

   for x= max_input:-1:1
     index=0
     for y=1:batchsize
        outBatch[:,x,y] = zeros(length(outDict))
       if x > length(inputStr[y])
         inBatch[:,max_input-x+1,y] = inPad
         mask[max_input-x+1,y] = 0
       else
         index = 1
         a = zeros(length(inDict))
         a[inDict[inputStr[y][index]]] = 1
         inBatch[:,max_input-x+1,y] = a
         index += 1
      end
    end
   end

   for y=1:batchsize
    inBatch[:,max_input+1,y] = inputEndMark
    a = zeros(length(outDict))
    a[outDict[outputStr[y][1]]] = 1
    outBatch[:,max_input+1,y] = a
   end

   for x=1:max_output-1
    for y=1:batchsize
      if x > length(outputStr[y])
        mask[max_input+1+x,y] = 0
        inBatch[:,max_input+1+x,y] = inPad
        
      else
        a = zeros(length(inDict))
        a[inDict[outputStr[y][x]]] = 1
        inBatch[:,max_input+1+x,y] = a
      end
      
      if x + 1 > length(outputStr[y])
        outBatch[:,max_input+1+x,y] = outPad
      else
        a = zeros(length(outDict))
        a[outDict[outputStr[y][x+1]]] = 1
       outBatch[:,max_input+1+x,y] = a
      end
      
    end
   end
   
   
   for y=1:batchsize
     outBatch[:,max_input+1+max_output,y] = outputEndMark
     if max_output > length(outputStr[y])
        inBatch[:,max_input+1+max_output,y] = inPad
        mask[max_input+1+max_output,y] = 0
     else
        a = zeros(length(inDict))
        a[inDict[outputStr[y][max_output]]] = 1
        inBatch[:,max_input+1+max_output,y] = outputStr[y][max_output]
     end

    inBatch[:,max_input+1+max_output+1,y] = inputEndMark
    outBatch[:,max_input+1+max_output+1,y] = zeros(length(outDict))
  end
    push!(dataX,inBatch)
    push!(dataY,outBatch)
    push!(dataMask,mask)
 end
end



function findMax(data)
  max = 0
  for x in data
    x = rstrip(x)
    if length(x) > max
      max = length(x)
    end
  end
  return max
end

#inDictionary should contains outDictionary's characters;
function SetDictionaries(inFile, outFile)
    open(inFile) do f
        for l in eachline(f)
                get!(inDict, l[1], 1+length(inDict))
        end
    end
    get!(inDict,'~',1+length(inDict))

    inputEndMark = zeros(length(inDict))
    inputEndMark[end] = 1

   inPad = zeros(length(inDict))
   inPad[1] = 1

    open(outFile) do f
        for l in eachline(f)
                get!(outDict, l[1], length(outDict))
        end
    end
    get!(outDict,'~',1+length(outDict))

     outputEndMark = zeros(length(outDict))
     outputEndMark[end] = 1
     outPad = zeros(length(outDict))
     outPad[1] = 1

     return inputEndMark,outputEndMark, inPad, outPad
end
