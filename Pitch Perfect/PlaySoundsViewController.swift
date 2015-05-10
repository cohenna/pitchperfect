//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Nick Cohen on 5/8/15.
//  Copyright (c) 2015 Nick Cohen. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var audioPlayer : AVAudioPlayer!
    var receivedAudio : RecordedAudio!
    
    var audioEngine : AVAudioEngine!
    var audioFile : AVAudioFile!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*if var path = NSBundle.mainBundle().pathForResource("greatballsoffire", ofType: "mp3") {
            //var url = NSURL(fileURLWithPath:path!)!
            var url = NSURL.fileURLWithPath(path)
        
            println(path)
            receivedAudio = RecordedAudio()
            receivedAudio.filePathUrl = url
        
            //var error:NSError?
            ////init!(contentsOfURL url: NSURL!, error outError: NSErrorPointer)
            //audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
            //audioPlayer.enableRate = true
        } else {
            println("could not find file path")
        }*/
        
        
        
        var error:NSError?
        //init!(contentsOfURL url: NSURL!, error outError: NSErrorPointer)
        println("receivedAudio:")
        println(receivedAudio.filePathUrl)
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: &error)
        audioPlayer.enableRate = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func resetPlayback() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.currentTime = 0.0
    }

    @IBAction func stopPlayback(sender: UIButton) {
        resetPlayback()
    }
    
    func playAudioWithVariableSpeed(speed:Float) {
        resetPlayback()
        audioPlayer.rate = speed
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @IBAction func slowPlayback(sender: UIButton) {
        playAudioWithVariableSpeed(0.5)
        println("slow playback")
    }
    
    @IBAction func fastPlayback(sender: UIButton) {
        playAudioWithVariableSpeed(2.0)
        println("fast playback")
    }
    
    
    @IBAction func playNormal(sender: UIButton) {
        playAudioWithVariableSpeed(1.0)
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
    
}
