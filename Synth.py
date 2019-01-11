from jinja2 import Environment, FileSystemLoader
import datetime

def capitalizeFirstLetterOnly(string):
    return string[:1].upper() + string[1:]

env = Environment(
    loader = FileSystemLoader('templates'),
    trim_blocks = True,
    lstrip_blocks = True
)
env.filters['capitalizeFirstLetterOnly'] = capitalizeFirstLetterOnly

vars = {
    'author': 'Shane Dunne',
    'year': str(datetime.datetime.now().year),
    'class': 'Synth',
    'AUID': 'AKsy',
    'baseClass': 'AKCoreSynth',
    'rampedParameters': [
        ('masterVolume', 1.0, 0.0, 1.0, 'fraction'),
        ('pitchBend', 2.0, -1000.0, 1000.0, 'semitones, signed'),
        ('vibratoDepth', 1.0, 0.0, 1000.0, 'semitones, usually < 1.0'),
        ('filterCutoff', 4.0, 0.0, 1000.0, 'ratio to playback pitch, 1.0 = fundamental'),
        ('filterStrength', 20.0, 0.0, 1000.0, 'same units as filterCutoff; amount filter EG adds to filterCutoff'),
        ('filterResonance', 0.0, 0.0, 20.0, 'decibels'),
        ],
    'rampedParameterInitValues': [
        
    ],
    'simpleParameters': [
        ('attackDuration', 0.0, 0.0, 10.0, 'seconds'),
        ('decayDuration', 0.0, 0.0, 10.0, 'seconds'),
        ('sustainLevel', 1.0, 0.0, 1.0, 'fraction'),
        ('releaseDuration', 0.0, 0.0, 10.0, 'seconds'),
        ('filterAttackDuration', 0.0, 0.0, 10.0, 'seconds'),
        ('filterDecayDuration', 0.0, 0.0, 10.0, 'seconds'),
        ('filterSustainLevel', 1.0, 0.0, 1.0, 'fraction'),
        ('filterReleaseDuration', 0.0, 0.0, 10.0, 'seconds'),
    ],
    'chunkSize': 16
}

template = env.get_template('AKDSP.hpp')
with open('AKSynthDSP.hpp', 'w') as outfile:
    outfile.write(template.render(vars).encode('utf-8'))

template = env.get_template('AKDSP.mm')
with open('AKSynthDSP.mm', 'w') as outfile:
    outfile.write(template.render(vars).encode('utf-8'))

template = env.get_template('AKAudioUnit.swift')
with open('AKSynthAudioUnit.swift', 'w') as outfile:
    outfile.write(template.render(vars).encode('utf-8'))

template = env.get_template('AKNode.swift')
with open('AKSynth.swift', 'w') as outfile:
    outfile.write(template.render(vars).encode('utf-8'))
