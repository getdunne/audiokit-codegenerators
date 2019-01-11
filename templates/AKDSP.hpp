//
//  AK{{ class }}DSP.hpp
//  AudioKit
//
//  Created by {{ author }}, revision history on Github.
//  Copyright © {{ year }} AudioKit. All rights reserved.
//

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AK{{ class }}Parameter)
{
    // ramped parameters
    
    {% for item in rampedParameters %}
    AK{{ class }}Parameter{{ item[0]|capitalizeFirstLetterOnly }},
    {% endfor %}

    // simple parameters

    {% for item in simpleParameters %}
    AK{{ class }}Parameter{{ item[0]|capitalizeFirstLetterOnly }},
    {% endfor %}

    // ensure this is always last in the list, to simplify parameter addressing
    AK{{ class }}ParameterRampDuration,
};

#ifndef __cplusplus

AKDSPRef createAK{{ class }}DSP(int channelCount, double sampleRate);
void doAK{{ class }}PlayNote(AKDSPRef pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency);
void doAK{{ class }}StopNote(AKDSPRef pDSP, UInt8 noteNumber, bool immediate);
void doAK{{ class }}SustainPedal(AKDSPRef pDSP, bool pedalDown);

#else

#import "AKDSPBase.hpp"
#include "AKCoreSynth.hpp"
#include "AKLinearParameterRamp.hpp"

struct AK{{ class }}DSP : AKDSPBase, {{ baseClass }}
{
    // ramped parameters
    {% for item in rampedParameters %}
    AKLinearParameterRamp {{ item[0] }}Ramp,
    {% endfor %}
    
    AK{{ class }}DSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
