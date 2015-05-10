//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nick Cohen on 5/8/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer : AVAudioPlayer!
    var receivedAudio : RecordedAudio!
    
    var audioEngine : AVAudioEngine!
    var audioFile : AVAudioFile!
    
    var pausedPlayer : Bool!
    var pausedEngine : Bool!

    @IBOutlet weak var playAndPauseButton: UIButton!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        // Cannot currently get notification that AVAudioEngine has stopped playback.
        // Notifications are not currently working for some reason, so we have a "bug" that the pause button doesn't 
        // change back to play after AVAudioEngine playback stops.  However, it's not the end of the world since the 
        // user can simply press the stop button to make things normal again.
        // TODO: figure out how to receive notifications that AVAudioEngine playback has stopped
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioEngineConfigurationChange:", name: AVAudioEngineConfigurationChangeNotification, object: audioEngine)

        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        pausedPlayer = false
        pausedEngine = false
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        println("audioPlayerDidFinishPlaying")
        resetPlayback()
        setButtonToPlay()
    }
    
    @objc private func audioEngineConfigurationChange(notification: NSNotification) -> Void {
        NSLog("Audio engine configuration change: \(notification)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func resetPlayback() {
        setButtonToPaused()
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.currentTime = 0.0
        pausedPlayer = false
        pausedEngine = false
    }
    
    func isPlaying() -> Bool {
        return audioPlayer.playing || audioEngine.running
    }
    
    func setButtonToPaused() {
        playAndPauseButton.setImage(UIImage(named: "pause"), forState: .Normal)
    }
    
    func setButtonToPlay() {
        playAndPauseButton.setImage(UIImage(named: "play"), forState: .Normal)
    }

    @IBAction func stopPlayback(sender: UIButton) {
        resetPlayback()
        setButtonToPlay()
    }
    
    func playAudioWithVariableSpeed(speed:Float) {
        resetPlayback()
        audioPlayer.rate = speed
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @IBAction func slowPlayback(sender: UIButton) {
        playAudioWithVariableSpeed(0.5)
    }
    
    @IBAction func fastPlayback(sender: UIButton) {
        playAudioWithVariableSpeed(2.0)
    }
    
    
    @IBAction func playNormal(sender: UIButton) {
        print("audioPlayer.playing: ")
        println(audioPlayer.playing)
        print("audioEngine.running: ")
        println(audioEngine.running)
        print("pausedPlayer: ")
        println(pausedPlayer)
        print("pausedEngine: ")
        println(pausedEngine)
        
        if (pausedPlayer!) {
            // resume player
            println("player was paused, resuming player")
            audioPlayer.play()
            pausedPlayer = false
            setButtonToPaused()
        }
        else if (pausedEngine!) {
            // resume engine
            println("engine was paused, resuming engine")
            audioEngine.startAndReturnError(nil)
            setButtonToPaused()
        }
        else if (audioPlayer.playing) {
            println("player is playing, pausing player")
            setButtonToPlay()
            pausedPlayer = true
            audioPlayer.pause()
        } else if (audioEngine.running) {
            println("engine is playing, pausing engine")
            setButtonToPlay()
            pausedEngine = true
            audioEngine.pause()
        } else {
            println("playing normal playback")
            playAudioWithVariableSpeed(1.0)
        }
        println("")
        
    }
    @IBAction func playChipmunkSounds(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    
    @IBAction func playDarthVaderSounds(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        resetPlayback()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()

    }
    
    
    @IBAction func playEcho(sender: UIButton) {
        resetPlayback()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var echoNode = AVAudioUnitDelay()
        echoNode.delayTime = NSTimeInterval(0.3)
        
        // Attach the audio effect node corresponding to the user selected effect
        audioEngine.attachNode(echoNode)
        
        // Connect Player --> AudioEffect
        audioEngine.connect(audioPlayerNode, to: echoNode, format: nil)
        // Connect AudioEffect --> Output
        audioEngine.connect(echoNode, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler:nil)
        
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
}
