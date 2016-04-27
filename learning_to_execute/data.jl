include("utils/operations.jl")
include("utils/symbolsManager.jl")
include("utils/variablesManager.jl")

type MyData
        x::Array{Float64,2}
        y::Array{Float64,2} 
end

type Operand
        expr::AbstractString
        eval::Int    
end

MyData()=MyData(zeros(1,1),zeros(1,1)) 
type State
         currently_loaded_seed::Int
         seed::Int
         len::Int
         kind::Int
         name::AbstractString
         data::MyData
         pos::Float64
         acc::Float64
         count::Int
         normal::Float64
         
end
State()=State(0,0,0,0,"",MyData(),0.0,0.0,0,0.0)
type Params
         current_length::Int
         target_length::Int
         seq_length::Int
         layers::Int
         batch_size::Int
         rnn_size::Int
end
Params()=Params(0,0,0,0,0,0)

global params =Params()

#first paramater of hardness is length of digits
#second paramater of hardness is the nesting number of operations
global hardness = (0,0)

global stack = [];

global state_train =State()
global state_val =State()
global state_test =State()

global G = [];

push!(G, ("small_loop_opr",small_loop_opr))
push!(G, ("equality_opr",equality_opr))
push!(G, ("smallmul_opr",smallmul_opr))
push!(G, ("vars_opr",vars_opr))
push!(G, ("pair_opr",pair_opr))
push!(G, ("ifstat_opr",ifstat_opr))

function to_data(code, var, output)
  x = []
  y = []
  output = @sprintf("%d.", output)
  input = ""
  
  for i in length(code)
    input = @sprintf("%s%s#", input, code[i])
  end
  
    input = @sprintf("%sprint(%s)@", input, var)
  
  for j in 1:length(input)
    push!(y, 0)
    push!(x, symbolsManager.get_symbol_idx(input[j]))
  end
  
  for j in 1:length(input)
    push!(x, symbolsManager.get_symbol_idx(output[j]))
    push!(y, symbolsManager.get_symbol_idx(output[j]))
  end
  
  orig = @sprintf("%s%s", input, output)
  
  return x, y, orig
end


function compose(hardness)
  stack = [];
  variablesManager.clean()
  
  funcs = Dict{Int, Any}()
  names = Dict{Int, Any}()
  
  for (i, v) in G
    if (contains(i, "_opr"))
      get!(funcs,length(funcs)+1, v)
      get!(names,length(names)+1, i)
    end
  end
  
  code = [];
  
  hard, nest = hardness;
  
  for h in 1:nest
    f_idx = rand(1:length(funcs))
    f = funcs[f_idx]
    code_tmp, var_tmp, output_tmp = f(hardness)
    for i in length(code_tmp) 
      code[length(code) + 1] = code_tmp[i]
    end
   push!(stack,((var_tmp, output_tmp)))
  end
  
  var, output = pop!(stack)
  
  return code, var, output
end


function get_operand(hardness)
  if size(stack,1) == 0
    eval = rand(10^(hardness-1):10^hardness)
    expr = @sprintf("%d", eval)
    return expr, eval
  else
    return pop!(stack)
  end
end


function load_data(state)
  if state.currently_loaded_seed == state.seed
    return
  else
    state.currently_loaded_seed = state.seed
    get_data(state) 
  end
end

function get_data(state)
  make_deterministic(state.seed)
  len = state.len
  batch_size = state.batch_size
  if state.data == nothing
    state.data = []
    state.data.x = ones(len, batch_size)
    state.data.y = zeros(len, batch_size)
  end
  x = state.data.x
  y = state.data.y
  count = 0
  @printf("Few exemplary newly generated ... \nsamples from the %s dataset:\n", state.name)
  idx = 1
  batch_idx = 1
  i = 0
  while true
    #data = to_data(compose(state.hardness))
    input, target, orig = to_data(compose(state.hardness))
    if hash(orig) % 3 == state.kind
      count = count + #orig
      if idx + lenght(input) > size(x,1)
        idx = 1
        batch_idx = batch_idx + 1
        if batch_idx > batch_size
          break;
        end
      end
     
      for j in length(input)
        x[idx][batch_idx] = input[j]
        y[idx][batch_idx] = target[j]
        idx = idx + 1
        # Added to take care of smaller state lens
        if idx > size(x,1)
          idx = 1 
          batch_idx = batch_idx + 1
          if batch_idx > batch_size 
            break
          end
        end
      end
      
      if batch_idx > batch_size
            break
      end 
      
      if i <= 2 
        io.write("\tInput:\t")
        orig = @sprintf("     %s", orig)
        orig = orig:gsub("#", "\n\t\t     ")
        orig = orig:gsub("@", "\n\tTarget:      ")
        io.write(orig)
        io.write("\n")
        io.write("\t-----------------------------\n")
        i = i + 1
      end
    end
  end
  io.write("\n")
end


function get_operands(hardness, nr)
  ret = []
  for i in nr
    expr, eval = get_operand(hardness)
    push!(ret,Operand(expr,eval))
  end
  shuffle!(ret)
  return ret
end

function hardness_fun()
  return 8, 4
end


  print("Data verification")
  for k  in 1:1000
    code, var, output = compose(hardness_fun)
    
    output = @sprintf("%d", output)
    print("\n__________________\n")
    input = ""
    
    for i in 1:length(code)
      input = @sprintf("%s%s\n", input, code[i])
    end
    input = @sprintf("%sprint(%s)", input, var)
    print(@sprintf("Input: \n%s\n", input))
    print(@sprintf("Target: %s", output))
    line = chomp(readall(`python2.7 -c $input`))

    if lines != output
       @printf("\nERROR!\noutput from python: '%s',...\ndoesn't match target output: '%s'", lines, output)
       quit()
   end
  end
  print("\n__________________\n")
  print("Successfully verified coherence of generated a " .. 
        "targets with python interpreter.")
