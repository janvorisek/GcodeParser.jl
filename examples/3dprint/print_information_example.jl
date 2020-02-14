module print_information_example

using GcodeParser;

function run()

    # create any data object
    # it will be passed as a second parameter to your callbacks
    # here simple dictionary is used to store information during the print
    myPrinter = Dict{String,Any}();
    myPrinter["positioning"] = "absolute";
    myPrinter["x"] = 0.;
    myPrinter["y"] = 0.;
    myPrinter["z"] = 0.;
    myPrinter["e"] = 0.;
    myPrinter["filamentUsage"] = 0.; # store total filament usage (printed length of filament)
    myPrinter["distanceMoved"] = 0.; # store total distance moved

    # Setup a dictionary of callbacks for specified commands
    callbacks = Dict{String,Function}();
    callbacks["G0"] = movement; # just move the printhead
    callbacks["G1"] = extrude;  # move the printhead as well as extrude material

    # watch out for relative and absolute positioning
    callbacks["G90"] = (cmds, dataobject)->dataobject["positioning"] = "absolute";
    callbacks["G91"] = (cmds, dataobject)->dataobject["positioning"] = "relative";

    # parse g-code file and simulate print using our own callbacks and data object
    parseFile("examples/3dprint/gcodes/AI3M_test.gcode", callbacks, myPrinter);

    # Show printer data after print with some interesting stats
    @show myPrinter;

    return;
end

"""
    movement(cmds, dataobject)

Example movement callback for `G0` and `G1` which calculates the total distance moved in all axes.

It is calculated by watching the `X`, `Y` and `Z` axes movement.
"""
function movement(cmds, dataobject)

    dx = 0.;
    dy = 0.;
    dz = 0.;

    x = findfirst((x->lowercase(x.first) == "x"), cmds);
    if x !== nothing
        val = parse(Float64, cmds[x].second);

        if dataobject["positioning"] === "absolute"
            dx = val - dataobject["x"];
            dataobject["x"] = val;
        else
            dx = val;
        end
    end

    y = findfirst((x->lowercase(x.first) == "y"), cmds);
    if y !== nothing
        val = parse(Float64, cmds[y].second);

        if dataobject["positioning"] === "absolute"
            dy = val - dataobject["y"];
            dataobject["y"] = val;
        else
            dy = val;
        end
    end

    z = findfirst((x->lowercase(x.first) == "z"), cmds);
    if z !== nothing
        val = parse(Float64, cmds[z].second);

        if dataobject["positioning"] === "absolute"
            dz = val - dataobject["z"];
            dataobject["z"] = val;
        else
            dz = val;
        end
    end

    dataobject["distanceMoved"] += sqrt(dx * dx + dy * dy + dz * dz);
end

"""
    extrude(cmds, dataobject)

Example extrusion callback for `G1` which calculates total length of filament extruded.

The extruded filament length is obtained by watching the `E` axis movement in the g-code file.
"""
function extrude(cmds, dataobject)
    movement(cmds, dataobject);

    # calculate used filament length
    e = findfirst((x->lowercase(x.first) == "e"), cmds);
    if e !== nothing
        # Current E axis value
        e = parse(Float64, cmds[e].second);

        # Printed length of a current move
        if dataobject["positioning"] === "absolute"
            de = e - dataobject["e"];
            dataobject["e"] = e;
        else
            de = e;
        end

        # Used filament
        dataobject["filamentUsage"] += de;
        # println(dataobject["filamentUsage"]);5
    end
end

end # module
