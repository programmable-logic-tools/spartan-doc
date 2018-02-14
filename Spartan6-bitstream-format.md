## Bitstream

When talking about a "bitstream" for a Spartan-6 FPGA,
one must specify, whether one is talking about:
* a Xilinx bitfile,
* a configuration command sequence or
* a file, storing configuration memory frames, which can be
  * in binary or
  * in ASCII representation.

Here the term bitstream will refer to the configuration command sequence.

## Tiles

Like any FPGA,
Spartan6-series FPGAs are a huge, two-dimensional grids of so-called tiles.

Generally, FPGA families feature only a limited set of tile types,
which must realize at least the essential requirements for configurable logic applications,
such as logic tiles, interconnection/routing tiles and I/O tiles.
On top of that they may also realize
"convenience" functionality,
such as an SPI interface tile.
The set of available tile types varies from series to series
and, of course, across FPGA manufacturers.

The Spartan6 series features the following tile types:
* CLB: Configurable Logic Block
* DSP: Digital Signal Processor
* IOI: Input/Output Interconnect
* CLK: Clock distribution
* BRAM: Block RAM
* IOB: Input/Output Block

## Configuration memory frames

Each tile on a Spartan6-series FPGA is associated
dedicated configuration memory,
that configures the function of that tile.
The configuration memory consists of frames,
which can only be erased and written as a whole.

Most frames consist of 65x 16-bit words [[UG380 v2.10, p.97]](http://www.xilinx.com/support/documentation/user_guides/ug380.pdf).

The size of a frame is always 130 Byte and carries mainly
the configuration for the primitives (e.g., 8 bytes per CLB) [[Koch et al. Demonstration Paper]](https://www.duo.uio.no/bitstream/handle/10852/8851/fpt10koch_demo.pdf).

* CLB: 31 frames
* DSP48: 23 frames
* BRAM: 24 frames

## Configuration command sequence

Spartan6-series FPGAs are configured using 16-bit commands,
which act on the FPGA's internal registers.
A stream of bits representing a list of such configuration commands (the "bitstream")
is serially shifted into the FPGA upon startup.
The FPGA's internal "processor" evaluates the commands and performs
the programmed register reads and writes.
Amongst other things,
those commands program the desired configuration frames
into the configuration memory.

## Xilinx bitfile

The output of Xilinx ISE is usually a bitfile (*.bit).
Additionally to the configuration command sequence
it contains meta-information,
such as the compiler revision
and the date and time of file creation.
This meta-information is not uploaded to the FPGA,
therefore a Xilinx bitfile is not required for the configuration of a
Spartan6 FPGA - having the configuration command sequence
in binary form (a.k.a. the bitstream) is sufficient.
However, for archiving and versioning purposes it might prove useful
to have the actual bitstreams bundled with their corresponding meta-information.
