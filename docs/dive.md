# Dive

A tool to explore docker images by layer

[github project](ihttps://github.com/wagoodman/dive)

## Examine image layer contents

One useful functionality of this tool is to examine the contents of each layer. For example, it revealed python bytecode (\*.pyc) files in the image that were taking up as much space as the python packages. That prompted some research to eliminate the bytecode files to significantly reduce the image size.

Here are the steps to recreate that view

1. Start the tool

    ```bash
    dive hackforlaops/mkdocs:testing
    ```

1. Move to the relevant layer using the arrow keys

1. Press ++tab++ to switch to layer view (moves cursor to the right pane)

1. Press ++ctrl+u++ to hide unmodified files in the layer

1. Press ++ctrl+o++ to sort by size to see what's taking up the most space

1. Press ++space++ to toggle collapse/expand directory contents
