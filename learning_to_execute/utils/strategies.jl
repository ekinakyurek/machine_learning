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
#]]--



function make_harder()

  state_train.seed = state_train.seed + 1
  state_val.seed = state_val.seed + 1
  
  if params.current_length < params.target_length
    params.current_length = params.current_length + 1
    return true
  else
    if params.current_nesting < params.target_nesting
      params.current_length = 1
      params.current_nesting = params.current_nesting + 1
      return true
    end
  end
  return false
end

function baseline()
  return params.target_length, params.target_nesting
end

function naive()
  return params.current_length, params.current_nesting
end

function mix()
  return rand(1:params.target_length),
         rand(1:params.target_nesting)
end

function blend()
  if rand(1:5) == 1
    return rand(1:params.target_length),
           rand(1:params.target_nesting)
  else
    return params.current_length, params.current_nesting
  end
end

function current_hardness()
  return params.current_length, params.current_nesting
end

function target_hardness()
  return params.target_length, params.target_nesting
end