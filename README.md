# GcodeParser

`GcodeParser` is a simple package for parsing G-code files. It has been tested on 3d printing G-codes produced by some of the common slicers (mostly `Slic3r` and `Cura`).

## Installation

You can install this package using the following Julia command:

```julia
Pkg.add("GcodeParser")
```

The package can then be loaded and used in a Julia script or a Jupyter Notebook by:

```julia
using GcodeParser
```

## Usage

To parse a single line of g-code use the `parseLine` function.

```julia
parseLine("G1 (move) X6.66 ; some command description")
```

This will return either an array of pairs (`["G" => "1", "X" => "6.66"]`) or an array of strings `["G1", "X6.66"]` if you call the method as `parseLine("G1...", false)`. Comments are striped out automatically.

### Parsing g-code file with custom callbacks

You can use the `parseFile` function to do more advanced calculations with your g-code.

```julia

# create any data object, it doesn't need to be a dictionary
# it will be passed as a second parameter to your callbacks
# here simple dictionary is used to store information during the print
myPrinter = Dict{String,Any}();
myPrinter["numberOfMoves"] = 0;

# Setup a dictionary of callbacks for specified commands
callbacks = Dict{String,Function}();
callbacks["G0"] = someFunction; # either use a function 
callbacks["G1"] = (cmds, dataobject)->dataobject["numberOfMoves"]++; # or use anonymous function

parseFile("examples/3dprint/gcodes/AI3M_test.gcode", callbacks, myPrinter);
```

Check out the `examples` folder to see a simple calculation of the total distance moved and filament consumption.

## Authors

* **Jan Vorisek** <[**jan@vorisek.me**](mailto:jan@vorisek.me)>

The regular expression for parsing a line of g-code is taken from  [**this**](https://github.com/cncjs/gcode-parser) javascript package.

## License

This project is licensed under the [MIT License](LICENSE.md).
