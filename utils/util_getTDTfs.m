function fs = util_getTDTfs(inp)

% C/O Jacob Westerberg, Schall Lab (2020)

if strcmp(inp, 'fast')
    fs = 24414.0625;
elseif strcmp(inp, 'slow')
    fs = 1017.2526;
end
 
end