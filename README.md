# pipe-fitting-SCAD

OpenSCAD script for generating pipe fittings parametrically.

## Overview

This repository contains a script for modeling a pipe fitting assembly, complete with gaskets, threaded nuts, and customizable pipe fittings. The script is designed for use in OpenSCAD and offers extensive customization for each component while adhering to existing industry thread standards.

<img src="docs/manufactured_1.jpg" alt="Images of the Manufactured Pipe Fitting 1" height="400"/>
<img src="docs/manufactured_2.jpg" alt="Images of the Manufactured Pipe Fitting 1" height="400"/>

## Dependencies

- OpenSCAD software.
- `threads-scad` library by rcolyer, available at [rcolyer/threads-scad](https://github.com/rcolyer/threads-scad).

## Installation

1. Ensure OpenSCAD is installed on your system.
3. Download the `threads-scad` library as well as this `pipe-fitting-scad` library.
3. Place both libraries in the OpenSCAD libraries directory (typically at `C:\Program Files\OpenSCAD\libraries` on Windows).

## Usage

### Creating your Fitting

Modify the dimensional variables at the beginning of the pfDesigner.scad script to customize the pipe, gasket, fitting, nuts, and threads.

<img src="docs/designer+output.jpg" alt="Designer Interface and Labelled Output" width="800"/>

### Manufacturing your Fitting

*Add part here about pettings and materials from paper.*

<img src="docs/slicer_view.jpg" alt="Slicer View for Manufacturing Fittings" width="800"/>

## How it Works

<img src="docs/pipefitting-program-flowchart_paper.jpg" alt="Programming Overview Flowchart" width="600"/>

## Contributing & Requests

Contributions to improve the script or extend its capabilities are welcome. Please submit pull requests with clear descriptions of changes and additions. Similarly, submit an issue to request a fix or addition with a clear description of the bug or feature to be addressed.

## License

This script is licensed under the GPL 3.0 or later. For more details, see the [LICENSE](LICENSE) file.

## Organization

[FAST Research Group](https://www.appropedia.org/FAST)