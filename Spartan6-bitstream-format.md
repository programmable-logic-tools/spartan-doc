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

Each tile on a Spartan6-series FPGA features
one dedicated configuration memory frame,
that configures the function of the tile.
Most frames consist of 65x 16-bit words = 1040 bits (TODO: list of tile types with frame sizes).
The meaning of each individual bit in a frame
depends on the tile type.

## Xilinx bitfile

The output of Xilinx ISE is usually a bitfile (*.bit).
Additionally to the configuration command sequence
it contains meta-information,
such as  the compiler revision
and the date and time of file creation.
