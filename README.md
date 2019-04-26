Igor Pro Graph Converter
========================

Publish your Igor Pro graphs to online Plotly graphs with 1-click!

[![Contour subplots in Igor Pro](http://i.imgur.com/9QKmUQb.png)](https://plot.ly/~test-runner/10)

# Installation Instructions

- Install the PlotlyFunctions.ipf Igor procedure file
  - It is possible just to load this with File->Open File->Procedure for each new 
    experiment
  - It is easier to place the PlotlyFunctions.ipr or a shortcut to PlotlyFunctions.ipf in 
    the directory `\Documents\WaveMetrics\Igor Pro 8 User Files\Igor Procedures` or 
    `Program Files (x86)\WaveMetrics\Igor Pro Folder\User Procedures`. This makes the 
    procedure file load every time Igor starts.

- The procedure will generate a standardized 
  plotly JSON file that can be loaded (and pushed) e.g. by python or manually.

# Usage

Create some data and a simple graph

```
make/N=10 testData={4,2,4,6,4,1,6,1,3,0}
display testData
```

Now send the data to plotly by either pressing ctrl-1, or executing the 
command:

```
Graph2plotly()
```

This writes a JSON string with the name of the current Experiment Name to the path where 
the Experiment is located.

