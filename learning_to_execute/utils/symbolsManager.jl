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

module SymbolsManager

global symbol2idx= Dict{Any,Int}()
global idx2symbol =  Dict{Int,Any}()
global vocab_size = 0

function get_symbol_idx(c)
  if haskey(dict, c)
     vocab_size = vocab_size + 1
     symbol2idx[c] = vocab_size
     idx2symbol[vocab_size] = c
  end
  return symbol2idx[c]
end

end