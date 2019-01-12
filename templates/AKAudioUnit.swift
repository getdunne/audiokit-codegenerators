//
//  AK{{ class }}AudioUnit.swift
//  AudioKit
//
//  Created by {{ author }}, revision history on Github.
//  Copyright © {{ year }} AudioKit. All rights reserved.
//

import AVFoundation

public class AK{{ class }}AudioUnit: AKGeneratorAudioUnitBase {

    func setParameter(_ address: AK{{ class }}Parameter, value: Double) {
        setParameterWithAddress(address.rawValue, value: Float(value))
    }

    func setParameterImmediately(_ address: AK{{ class }}Parameter, value: Double) {
        setParameterImmediatelyWithAddress(address.rawValue, value: Float(value))
    }

    var rampDuration: Double = 0.0 {
        didSet { setParameter(.rampDuration, value: rampDuration) }
    }

    {% for item in rampedParameters + simpleParameters %}
    var {{ item[0] }}: Double = {{ item[1] }} {
        didSet { setParameter(.{{ item[0] }}, value: {{ item[0] }}) }
    }

    {% endfor %}
    public override func initDSP(withSampleRate sampleRate: Double,
                                 channelCount count: AVAudioChannelCount) -> AKDSPRef {
        return createAK{{ class }}DSP(Int32(count), sampleRate)
    }

    override init(componentDescription: AudioComponentDescription,
                  options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        let nonRampFlags: AudioUnitParameterOptions = [.flag_IsReadable, .flag_IsWritable]

        var parameterAddress: AUParameterAddress = 0

        {% for item in rampedParameters %}
        let {{ item[0] }}Parameter = AUParameterTree.createParameter(
            identifier: "{{ item[0] }}",
            name: "{{ item[0] }}",            // TODO: fix human-readable parameter name
            address: parameterAddress,
            range: {{ item[2] }}...{{ item[3] }},
            unit: .generic,             // TODO: fix unit
            flags: .default)            // TODO: fix flags

        parameterAddress += 1

        {% endfor %}
        {% for item in simpleParameters %}
        let {{ item[0] }}Parameter = AUParameterTree.createParameter(
            identifier: "{{ item[0] }}",
            name: "{{ item[0] }}",         // TODO: fix human-readable parameter name
            address: parameterAddress,
            range: {{ item[2] }}...{{ item[3] }},
            unit: .generic,             // TODO: fix unit
            flags: nonRampFlags)        // TODO: fix flags

        parameterAddress += 1

        {% endfor %}
        setParameterTree(AUParameterTree(children: [
            {% for item in rampedParameters %}
            {{ item[0] }}Parameter,
            {% endfor %}
            {% for item in simpleParameters %}
            {{ item[0] }}Parameter,
            {% endfor %}
            ]))

        {% for item in rampedParameters + simpleParameters %}
        {{ item[0] }}Parameter.value = {{ item[1] }}
        {% endfor %}
    }

    public override var canProcessInPlace: Bool { return true }

    public func playNote(noteNumber: UInt8,
                         velocity: UInt8,
                         noteFrequency: Float) {
        doAK{{ class }}PlayNote(dsp, noteNumber, velocity, noteFrequency)
    }

    public func stopNote(noteNumber: UInt8, immediate: Bool) {
        doAK{{ class }}StopNote(dsp, noteNumber, immediate)
    }

    public func sustainPedal(down: Bool) {
        doAK{{ class }}SustainPedal(dsp, down)
    }

    override public func shouldClearOutputBuffer() -> Bool {
        return true
    }

}
