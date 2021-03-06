...how it is realised in the YoSys + Arachne + iCEstorm toolchain
and
how it could be realised for the Xilinx Spartan-6 toolchain.

## Synthesis

Synthesis is the process of
compiling source files
written in a **hardware description language** (HDL),
e.g. Verilog or VHDL,
to a netlist of digital logic building blocks,
e.g. LUTs and D-Flipflops,
and the subsequent **mapping** of those blocks to device-specific **primitives**,
e.g. SB_LUT4 for iCE40 FPGAs.
Amongst other things,
YoSys is capable of compiling Verilog
to most of the primitives that are available in Lattice iCE40-FPGAs
(as of 2018-02).
The output of the synthesis is the netlist
containing a list of FPGA tiles with (abstract) configuration
alongside information about how to interconnect the inputs and outputs of those tiles.

<a href="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-synthesis.png">
<img width="450px" type="image/svg+xml" src="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-synthesis.png"/>
</a>

Excerpt from a **BLIF** netlist generated by **YoSys**:
```blif
...
.gate SB_LUT4 I0=mysignal1 I1=mysignal2 I2=mysignal3 I3=mysignal4 O=myderivedsignal
.param LUT_INIT 0000111110111011
...
```
The above example shows a BLIF representation of an iCE40 lookup table (SB_LUT4)
as it was inferred by YoSys
to realize a logic provided in the form of a Verilog source file.
As one can see, the above LUT gets four inputs signals (I0-4) and provides one output signal (O).
In the second line the LUT's truth table is configured.
The truth table values define
the value of the output signal
for all 16 possible combinations of input signal values (2^4).

The outputs of a primitive are input to one or several others.
The idea is, that the totality of interconnected primitives
realizes the desired logical flow.
The tile interconnections are also called nets.
Nets can only represent one signal
and thus only have one logical value i.e. voltage at a time,
but they can connect two or more inputs with one output,
thereby establishing a network involving multiple primitives.
Nets are identified by their name.
Some net names are derived from the design source (and therefore human-readable),
others are generated by the synthesis tool.

### Synthesis for the Spartan-6

Apparently it is already possible to synthesize for Xilinx FPGAs with YoSys (command: "synth_xilinx").

## Place and Route (PnR)

The place-and-route (pnr) tool is usually started
with specific information about
which FPGA device to perform tile placement for.
It knows about the real arrangement of tiles on the FPGA die,
i.e. about the number and position of available primitives
as well as the signal delay times between them.
It imports the previously synthesized, device-specific **netlist**,
and elaborates a possible **floorplan** for it,
by assigning all primitives in the netlist a position on the die (placing)
and then realizing all interconnections using the die's interconnection capabilities (routing).
The goal of the pnr tool is to minimize interconnection lengths
and thus signal delay from one primitive to the next.
This is usually realized via methods of simulated annealing.

The final floorplan contains explicit configuration information
about all tiles
present on an FPGA.
This information can be abstract (as in the netlist above)
or binary.
In the latter the abstract tile configuration
is already transpiled to a stream of bits.

<a href="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-pnr.png">
<img width="300px" type="image/svg+xml" src="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-pnr.png"/>
</a>

**Arachne-PnR** is capable of importing BLIF netlists
generated by YoSys
and place all iCE40 primitives on a given iCE40 FPGA.
The output is a ASC file,
which contains an ASCII representation of of all FPGA tiles
(even the ones not used be the individual design)
alongside their corresponding tile configuration bits
in human-readable format.

Example of the first lines of a pnr'ed design in ASC format, as generated by arachne-pnr:
```asc
.comment arachne-pnr 0.1+262+1 (git sha1 5403777, g++ 7.2.0-19 -O3 -DNDEBUG)
.device 5k
.io_tile 1 0
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000100
000000000000001000
.io_tile 2 0
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000000
000000000000000100
000000000000001000
.io_tile 3 0
...
```

### Place and Route for Spartan-6

As of now there is no support for Xilinx FPGAs in Arachne-PnR
or any other Open Source PnR tool.

## Bitstream Packing

Once the **floorplan** for an FPGA has been elaborated,
there is little left to do but to pack the generated configuration
into a file,
that can be stored either in the FPGA itself
or in a non-volatile memory IC connected to the FPGA.
In the latter case,
the FPGA reads the memory IC upon startup
and configures itself from the contained binary,
which is mostly referred to as the **bitstream**.
Those memory ICs are usually connected via a serial bus (SPI).

Although this sounds like a simple task,
it is a major bottleneck in (Open Source) toolchain development,
because - unfortunately - the corresponding companies (Xilinx, Altera, Lattice, ...)
provide little to no documentation about how to format bitstreams for their FPGAs.
Therefore toolchain development must often rely on reverse-engineering.

The **iCEstorm** project provides the tool **icepack**,
which facilitates the conversion
from the ASCII representation of the floorplan
to the bitstream.

<a href="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-packer-ice40.png">
<img width="160px" type="image/svg+xml" src="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-packer-ice40.png"/>
</a>

### Bitstream packing for Spartan-6

The bitstream packing is a little different in Spartan-6 FPGAs:

<a href="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-packer-spartan6.png">
<img width="400px" type="image/svg+xml" src="https://raw.githubusercontent.com/wiki/matthiasbock/spartantools/flow-packer-spartan6.png"/>
</a>

There is an additional step in comparison to iCE40 FPGAs:
Apparently the bitstream is not merely shifted into the FPGA for configuration.
Instead,
it seems to consist of **programming instructions**,
which are interpreted by a very simple state machine or "processor" in the FPGA,
which in turn facilitates the actual tile configuration.
This additional step makes it necessary
to implement a programming instruction generator.
It shall read the binary floorplan,
append the required programming instructions
and output to an intermediate, human-readable file,
which's format will be referred to here as **bitstream programming language** (BPL).
The human-readable BPL can then be exported to it's **binary** equivalent (BIN).

Optionally, headers and **meta-information** can be added
in order to create a file in the **Xilinx BIT** file format.
