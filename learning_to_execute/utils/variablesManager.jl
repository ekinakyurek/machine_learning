#[[
# Copyright 2014 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#]]--

module variablesManager
vars = [];
last_var_idx = 0


function get_unused_variables(number)
  ret = [];
  if length(vars) == 0
    vars = randperm(10) .+ Int('a') - 1
  end
  for i in 1:number
    push!(ret, Char(vars[i + last_var_idx]))
  end
  last_var_idx = last_var_idx + number
  return ret
end

function clean()
  vars = []
  last_var_idx = 0
end


end