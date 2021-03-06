/*
Copyright (c) 2015, Alex S. Glomsaas
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

class Streamable: NSObject, InlineMediaHandler, InlineMediaPreferenceHandler {
    @IBOutlet weak var automaticallyPlayAudioCheckbox: NSButton!
    @IBOutlet weak var displayVideoAsPausedCheckbox: NSButton!
    @IBOutlet var preferenceView: NSView!
    
    static func name() -> String {
        return "Streamable"
    }
    
    static func icon() -> NSImage? {
        return NSImage.fromAssetCatalogue("Streamable")
    }
    
    func preferences() -> NSView? {
        return self.preferenceView
    }
    
    override func awakeFromNib() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        self.automaticallyPlayAudioCheckbox.state = defaults.integerForKey("streamableAutomaticallyPlayAudio")
        self.displayVideoAsPausedCheckbox.state = defaults.integerForKey("streamableDisplayVideoAsPaused")
    }
    
    required override init() {
        super.init()
        let defaultConfiguration: [String : AnyObject] = [
            "streamableAutomaticallyPlayAudio": 0,
            "streamableDisplayVideoAsPaused": 0
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultConfiguration)
        
        NSBundle(forClass: object_getClass(self)).loadNibNamed("Streamable", owner: self, topLevelObjects: nil)
    }
    
    required convenience init(url: NSURL, controller: TVCLogController, line: String) {
        self.init()
        /* Get the mp4 version of this link  */
        if let requestString = url.URLByDeletingPathExtension?.pathComponents?[1] {
            let videoUrl = "https://cdn.streamable.com/video/mp4/\(requestString).mp4"
            
            self.performBlockOnMainThread({
                let defaults = NSUserDefaults.standardUserDefaults()
                
                /* Create the video tag and set it to automatically play, and loop continously. */
                let automaticallyPlay = Bool(defaults.integerForKey("streamableAutomaticallyPlayAudio"))
                let playAudio = Bool(defaults.integerForKey("streamableDisplayVideoAsPaused"))
                let video = controller.createInlineVideo(videoUrl, loop: true, autoPlay: automaticallyPlay, muteAudio: !playAudio)
                
                /* Insert the element into Textual's view. */
                controller.insertInlineMedia(line, node: video, url: url.absoluteString)
            })
        }
    }
    
    @IBAction func automaticallyPlayAudioChange(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(sender.state, forKey: "streamableAutomaticallyPlayAudio")
        defaults.synchronize()
    }
    
    @IBAction func displayVideoAsPausedChange(sender: NSButton) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(sender.state, forKey: "streamableDisplayVideoAsPaused")
        defaults.synchronize()
    }
    
    static func matchesServiceSchema(url: NSURL) -> Bool {
        return url.host?.hasSuffix("streamable.com") == true && url.path?.characters.count > 3
    }
}
