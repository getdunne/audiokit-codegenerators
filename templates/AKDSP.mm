//
//  AK{{ class }}DSP.mm
//  AudioKit
//
//  Created by {{ author }}, revision history on Github.
//  Copyright © {{ year }} AudioKit. All rights reserved.
//

#import "AK{{ class }}DSP.hpp"
#include <math.h>

extern "C" void *createAK{{ class }}DSP(int channelCount, double sampleRate) {
    return new AK{{ class }}DSP();
}

extern "C" void doAK{{ class }}PlayNote(void *pDSP, UInt8 noteNumber, UInt8 velocity, float noteFrequency)
{
    ((AK{{ class }}DSP*)pDSP)->playNote(noteNumber, velocity, noteFrequency);
}

extern "C" void doAK{{ class }}StopNote(void *pDSP, UInt8 noteNumber, bool immediate)
{
    ((AK{{ class }}DSP*)pDSP)->stopNote(noteNumber, immediate);
}

extern "C" void doAK{{ class }}SustainPedal(void *pDSP, bool pedalDown)
{
    ((AK{{ class }}DSP*)pDSP)->sustainPedal(pedalDown);
}


AK{{ class }}DSP::AK{{ class }}DSP() : AKCore{{ class }}()
{
    {% for item in rampedParameters %}
    {{ item[0] }}Ramp.setTarget({{ item[1] }}, true);
    {% endfor %}
}

void AK{{ class }}DSP::init(int channelCount, double sampleRate)
{
    AKDSPBase::init(channelCount, sampleRate);
    AKCore{{ class }}::init(sampleRate);
}

void AK{{ class }}DSP::deinit()
{
    AKCore{{ class }}::deinit();
}

void AK{{ class }}DSP::setParameter(uint64_t address, float value, bool immediate)
{
    switch (address) {
        case AK{{ class }}ParameterRampDuration:
            {% for item in rampedParameters %}
            {{ item[0] }}Ramp.setRampDuration(value, sampleRate);
            {% endfor %}
            break;

        {% for item in rampedParameters %}
        case AK{{ class }}Parameter{{ item[0]|capitalizeFirstLetterOnly }}:
            {{ item[0] }}Ramp.setTarget(value, immediate);
            break;
        {% endfor %}

        {% for item in simpleParameters %}
        case AK{{ class }}Parameter{{ item[0]|capitalizeFirstLetterOnly }}:
            // TODO: put your code to SET this parameter here
            break;
        {% endfor %}
    }
}

float AK{{ class }}DSP::getParameter(uint64_t address)
{
    switch (address) {
        case AK{{ class }}ParameterRampDuration:
            return {{ rampedParameters[0][0] }}Ramp.getRampDuration(sampleRate);

        {% for item in rampedParameters %}
        case AK{{ class }}Parameter{{ item[0]|capitalizeFirstLetterOnly }}:
            return {{ item[0] }}Ramp.getTarget();
        {% endfor %}

        {% for item in simpleParameters %}
        case AK{{ class }}Parameter{{ item[0]|capitalizeFirstLetterOnly }}:
            // TODO: put your code to GET this parameter here
            break;
        {% endfor %}
    }
    return 0;
}

void AK{{ class }}DSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{
    for (int frameIndex = 0; frameIndex < frameCount; frameIndex += {{ chunkSize }}) {
        int frameOffset = int(frameIndex + bufferOffset);
        int chunkSize = frameCount - frameIndex;
        if (chunkSize > {{ chunkSize }}) chunkSize = {{ chunkSize }};

        // ramp parameters
        {% for item in rampedParameters %}
        {{ item[0] }}Ramp.advanceTo(now + frameOffset);
        {{ item[0] }} = (float){{ item[0] }}Ramp.getValue();
        {% endfor %}
        
        // get data
        float *outBuffers[2];
        outBuffers[0] = (float *)outBufferListPtr->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float *)outBufferListPtr->mBuffers[1].mData + frameOffset;
        unsigned channelCount = outBufferListPtr->mNumberBuffers;
        AKCore{{ class }}::render(channelCount, chunkSize, outBuffers);
    }
}
