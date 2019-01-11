//
//  AK{{ class }}.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

/// {{ class }}
///
@objc open class AK{{ class }}: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AK{{ class }}AudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "{{ AUID }}")

    // MARK: - Properties

    @objc public var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    {% for item in rampedParameters %}
    fileprivate var {{ item[0] }}Parameter: AUParameter?
    {% endfor %}

    {% for item in simpleParameters %}
    fileprivate var {{ item[0] }}Parameter: AUParameter?
    {% endfor %}

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }
    
    {% for item in rampedParameters %}
    /// {{ item[0] }}   TODO: fix title
    @objc open dynamic var {{ item[0] }}: Double = {{ item[1] }} {
        willSet {
            guard {{ item[0] }} != newValue else { return }

            if internalAU?.isSetUp ?? false {
                if token != nil && {{ item[0] }}Parameter != nil {
                    {{ item[0] }}Parameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.{{ item[0] }} = newValue
        }
    }

    {% endfor %}
    {% for item in simpleParameters %}
    @objc open dynamic var {{ item[0] }}: Double = {{ item[1] }} {
        willSet {
            guard {{ item[0] }} != newValue else { return }
            internalAU?.{{ item[0] }} = newValue
        }
    }

    {% endfor %}
    // MARK: - Initialization

    /// Initialize this {{ class }} node
    ///
    /// - Parameters:
    {% for item in rampedParameters + simpleParameters %}
    ///   - {{ item[0] }}: {{ item[2] }} - {{ item[3] }}, {{ item[4] }}
    {% endfor %}
    ///
    @objc public init(
        {% for item in rampedParameters + simpleParameters %}
        {{ item[0] }}: Double = {{ item[2] }},
        {% endfor %}

        {% for item in rampedParameters + simpleParameters %}
        self.{{ item[0] }} = {{ item[0] }}
        {% endfor %}

        AK{{ class }}.register()

        super.init()

        AVAudioUnit._instantiate(with: AK{{ class }}.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        {% for item in rampedParameters + simpleParameters %}
        self.{{ item[0] }}Parameter = tree["{{ item[0] }}"]
        {% endfor %}

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard self != nil else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        {% for item in rampedParameters + simpleParameters %}
        self.internalAU?.setParameterImmediately(.{{ item[0] }}, value: {{ item[0] }})
        {% endfor %}
    }

    @objc open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.playNote(noteNumber: noteNumber, velocity: velocity, noteFrequency: Float(frequency))
    }

    @objc open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: false)
    }

    @objc open func silence(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber: noteNumber, immediate: true)
    }

    @objc open func sustainPedal(pedalDown: Bool) {
        internalAU?.sustainPedal(down: pedalDown)
    }
}
