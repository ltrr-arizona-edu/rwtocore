# Rwtocore: Convert Tree-Ring Measurements to Drawings of Cores

## Background

Much effort has been spent in recording the widths of the growth rings that many trees form each year. Dendrochronology, the science of tree-ring dating, makes extensive use of time series of such measurements, where the width is can be assigned to the year in which the ring formed, and although it also other parameters (such as wood density measurements), series of ring widths are still the most common. Occasionally it would be useful to reverse the process of measurement and turn a series of ring widths into a drawing of the growth rings that produced them. Time series graphs are much better than such drawings for interpreting the measurements, and the stylized bar graphs known as skeleton plots are better for dating, but sometimes for training or display purposes a more literal drawing is useful, particularly if images of the original rings are not to hand, or there are confounding factors that mask the clarity of the growth pattern.

### Cores

A core is a common type of tree-ring sample; simple sampling devices, increment borers, can remove a pencil-thin biopsy of wood from a living tree without killing it, and although other types of sample are also commonly used (such as complete disks cut across the stem), Rwtocore only draws images of cores. In the case of living trees, the outermost part of the core will often have the bark, preceded by the most recently formed rings. The core will always be mounted so that the wood fibers are perpendicular to the surface, so in an idealized tree with circular rings the ring boundaries will be arcs of circles with larger radii at the outside, becoming progressively smaller in the parts of the tree nearer its center. Some cores will pass through the center of the tree, the pith, surrounded by the rings with the smallest diameters, but in practice many cores do not reach the pith, even in trees where it has not been lost to heartrot and other disturbances. In the wood of conifers the ring boundaries are marked by the transition from the dark wood with small closely packed cells that formed at the end of the growing season (latewood) to the light-colored wood with large thin-walled cells (earlywood). Rwtocore draws a pale-colored rectangle representing the earlywood as the background for the entire core, and darker arcs representing the latewood on top of this to define the rings. In reality the relative widths of latewood and earlywood convey additional potentially useful information, but in the simulated cores this is always a fixed ratio. The wood of non-coniferous trees (oaks, for example) can have ring boundaries defined by much more complicated anatomical structures, but Rwtocore is incapable of drawing these.

### Measurements

Rwtocore reads measurements from text files in a format produced by obsolete measuring software, RW format. This is essentially just a column of numbers in ASCII text with almost now metadata at the start of the file. Some measurements from old equipment may be in this format, but almost any more sophisticated format can be downgraded to RW; the cross-platform conversion program TRiDAS is the recommended way to do this. Rwtocore can display multiple series of measurements together, conceptually on the same page.

### Drawings

Rwtocore produces its drawings in SVG (Scalable Vector Graphic) format, which many current web browsers can display directly (without needing any extensions or plug-ins) and many vector graphic editing programs such as Inkscape or Adobe Illustrator can read.

### Sub-series

Rwtocore normally draws all the rings in a series, but if there are many rings they may become difficult to see distinctly, so it can optionally display just a sub-series of limited length. The default drawing places the pith of the tree at the start of the first ring, although in the actual tree it will almost always be in some other position, so in addition to having a displayable sub-series taken from the start of the full series of measurements, Rwtocore can also have sub-series positioned at the end, possibly with more realistic ring patterns.

## Running

A simple command-line application `rwtocore` handles the common case of reading series of ring-width measurements from one or more files and writing the drawings in SVG format. The built-in help displays:

    Usage: rwtocore [options] rwfile [rwfile ...]
    
    Options:
        -m, --maxlength RINGS  Maximum number of rings; if positive, count from the start, if negative, count from the end
        -v, --version          Show version
        -h, --help             Show this message

In practice, since the SVG output appears on Standard Output rather than in a file, this will almost always follow the pattern

    rwtocore width_file.rw > drawing.svg_

The `maxlength` option selects the displayable sub series, and if omitted it will draw the full length of each series.

## Code

The code for Rwtocore follows the usual layout for a gem with Bundler managing any dependencies on other gems. The only important dependency is on Builder, which generates the SVG output directly (no graphics gems or libraries are involved). The tests use the spec-like interface to Minitest, and the non-trivial tests need Nokogiri to parse the SVG output. The generic instructions for including it in your own code apply as a gem apply.