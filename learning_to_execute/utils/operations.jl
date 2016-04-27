#[[
#  Copyright 2014 Google Inc. All Rights Reserved.
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#      http://www.apache.org/licenses/LICENSE-2.0
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#]]

#hardness is a tuple of (length,nesting)


function pair_opr(hardness)
  a, b = get_operands(hardness, 2)
  if rand(1:2) == 1
    eval = a.eval + b.eval
    expr = @sprintf("(%s+%s)", a.expr, b.expr)
  else
    eval = a.eval - b.eval
    expr = @sprintf("(%s-%s)", a.expr, b.expr)
  end
  return [], expr, eval
end

function smallmul_opr(hardness)
  expr, eval = get_operand(hardness)
  b = rand(1:4 * hardness[1])
  eval = eval * b
  if random(1:2) == 1
    expr = @sprintf("(%s*%d)", expr, b)
  else
    expr = @sprintf("(%d*%s)", b, expr)
  end
  return [], expr, eval
end

function equality_opr(hardness)
  expr, eval = get_operand(hardness)
  return [], expr, eval
end

function vars_opr(hardness)
  var = variablesManager.get_unused_variables(1)
  a, b = get_operands(hardness, 2)
  code=[];
  if random(1:2) == 1
    eval = a.eval + b.eval
    code = push!(code,@sprintf("%s=%s;", var, a.expr))
    expr = @sprintf("(%s+%s)", var, b.expr)
  else
    eval = a.eval - b.eval
    code = push!(code,@sprintf("%s=%s;", var, a.expr))
    expr = @sprintf("(%s-%s)", var, b.expr)
  end
  return code, expr, eval
end

function small_loop_opr(hardness)
  r_small = hardness[1]
  var = variablesManager.get_unused_variables(1)
  a, b = get_operands(hardness, 2)
  loop = rand(1:4 * hardness[1])
  op = ""
  val = 0
  if random(1:2) == 2
    op = "+"
    eval = a.eval + loop * b.eval
  else
    op = "-"
    eval = a.eval - loop * b.eval
  end
  code = [@sprintf("%s=%s", var, a.expr),
                @sprintf("for x in range(%d):%s%s=%s", loop, var,
                                                            op, b.expr)] ##DBG 5 VALUE IN ORIGIN
  expr = var
  return code, expr, eval
end

function ifstat_opr(hardness)
  r_small = hardness[1]
  a, b, c, d = get_operands(hardness, 4)
  if rand(1:2) == 1
    name = ">"
    if a.eval > b.eval
      output = c.eval
    else
      output = d.eval
    end
  else
    name = "<"
    if a.eval < b.eval
      output = c.eval
    else
      output = d.eval
    end
  end
  expr = @sprintf("(%s if %s%s%s else %s)",
                             c.expr, a.expr, name, b.expr, d.expr)
  return [], expr, output
end