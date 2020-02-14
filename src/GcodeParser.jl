module GcodeParser

"""
    stripComments(line::String)::String

Return a copy of string `line` with stripped comments inside parentheses and all characters after a semicolon.

This function also removes whitespace as it it not needed for further parsing.

# Examples
```julia-repl
julia> stripComments("G92 (G10(aaa)))) ((comment)G) Z0.2 ; this is a comment")
"G92Z0.2"
```
"""
function stripComments(line::String)::String
    re1 = r"\(.*\)";    # Remove anything inside the outer parentheses
    re2 = r"[^:]\;.*";  # Remove anything after a semi-colon to the end of the line, including preceding spaces

    line = replace(line,  re1 => s"");
    line = replace(line,  re2 => s"");
    line = filter(x -> !isspace(x), line) # Remove whitespace

    return line;
end

"""
    parseLine(line::String, returnPair::Bool = true)::Array{Union{String,Pair{String,String}},1}

Parse a single line of g-code and return an array of `Pair{String,String}` or an array of `String` containing the parsed commands.

The first command usually defines what to do (ie. `G01` - linear interpolation) and following commands are the arguments (ie. `X 14.312`);

# Examples
```julia-repl
julia> parseLine("G10 X5.Y3. E6.")
4-element Array{Union{Pair{String,String}, String},1}:
 "G" => "10"
 "X" => "5."
 "Y" => "3."
 "E" => "6."
```

Return array of strings
```julia-repl
julia> parseLine("G10 X5.Y3. E6.", false)
4-element Array{Union{Pair{String,String}, String},1}:
 "G10"
 "X5."
 "Y3."
 "E6."
```
"""
function parseLine(line::String, returnPair::Bool = true)::Array{Union{String,Pair{String,String}},1}
    line = stripComments(line);

    # Match commands
    gcode_regex = r"/(%.*)|({.*)|((?:\$\$)|(?:\$[a-zA-Z0-9#]*))|([a-zA-Z][0-9\+\-\.]+)|(\*[0-9]+)/igm";

    # array of matched strings
    matches = collect(String(m.match) for m in eachmatch(gcode_regex, line));

    if returnPair
        return collect(first(m, 1) => last(m, length(m) - 1) for m in matches);
    end

    return matches;
end

function parseFile(path::String, callbacks::Dict{String,Function}, dataObject)
    open(path) do f
        line = 1
        while !eof(f)
            x = readline(f);
            cmds = parseLine(x);
            if length(cmds) == 0 continue; end;

            letter = cmds[1].first;
            number = cmds[1].second;

            command = "$letter$number";
            if haskey(callbacks, command)
                if dataObject === nothing
                    callbacks[command](cmds);
                else
                    callbacks[command](cmds, dataObject);
                end
            end

            line += 1;
        end
    end
end

export parseLine;
export parseFile;

end # module
