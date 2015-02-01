# DyeSVG

If you have an SVG File with color information, you can remove the RGB attributes and insert SVG color information via a CSS File. This is useful if you generate your SVGs from PDFs or something similar but you want to stay flexible when it comes to the colors you choose for your website. Simply replace the CSS File and let DyeSVG copy the colors into your SVGs.


Compiling
--------------
Dependencies:
 - Haskell Platform (https://www.haskell.org/platform/)
 - Text.XML.Light package

As far as I recall anything else is already included in the Haskell Platform.

Once you have all the dependencies, you can simply type 'make' in the 'src' directory. This will generate the 'dyesvg' executable.


Usage
--------------
If you forgot how to use dyesvg, simply type it into the command line without any arguments. It takes at least two arguments, as follows

      $ dyesvg CSSFile SVGFile [SVGFile ...]

The CSSFile contains a CSS statement of the following form:

      svg { fill: #B43104; stroke: #B43104; }

Both 'fill' and 'stroke' are necessary to completely dye the SVG. After the CSSFile argument, you can insert any number of SVGFiles which will all be handled in the same way.

dyesvg will remove all the RGB statements within any tags and insert a style tag into the SVG. After the removal of all RGB statements, the CSS within the style tag shouldn't be overridden anymore.


Example
--------------
Go to the 'example' directory and open the example\_1.svg and example\_2.svg files in your browser. You can see a diagram and a formula. We want to change the colors to a fancy red which has the HTML color code #B43104. Take a look into the svg.css file in the example directory to see how this is done. 

Then we'll run dyesvg like this

        $ ../src/dyesvg svg.css example_1.svg example_2.svg

You can also type 'make' instead. 

Two new files will be generated: example\_1\_dyed.svg and example\_2\_dyed.svg. Open them up in your browser to see the effects. Note that the opacity in the diagram of example\_1.svg is unaffected.
