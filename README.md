# audiokit-codegenerators
Wrapper generators for [AudioKit](https://github.com/AudioKit/AudioKit) nodes, based on [Jinja2](http://jinja.pocoo.org/) templates.

Works fine in the Python v2.7 installed by default on macOS Mojave, BUT you'll need to install Jinja32 as
```
sudo easy_install Jinja2
```

Actually I did
```
sudo easy_install pip
sudo pip Jinja2
```
because I'm used to *pip*.

Once you've done that, run (in this directory):
```
python Synth.py
```
This will create four files, which collectively wrap the C++ *AKCoreSynth* class defined in *AudioKitCore/Synth/AKCoreSynth*[.hpp|.cpp], for use from in an AudioKit Swift program.
* *AKSynthDSP.hpp*: Objective-C header, based on *templates/AKDSP.hpp*
* *AKSynthDSP.mm*: Objective-C wrapper for *AKCoreSynth* C++ code, based on *templates/AKDSP.mm*
* *AKSynthAudioUnit.swift*: Swift AU class, based on *templates/AKAudioUnit.swift*
* *AKSynth.swift*: Top-level *AKPolyphonicNode*-derived class, based on *templates/AKNode.swift*

These are almost identical to the existing files in *AudioKit/AudioKit/Common/Nodes/Generators/Polysynths/Synth*, except for one spot in the generated *AKSynthAudioUnit.swift* where an extra comma is generated (too much work to fix this in the template), and several spots marked with *TODO* comments.

The idea of all this is to provide a basis for additional polysynth nodes based on C++ code in AudioKit Core and/or additional code written in a similar fashion.
