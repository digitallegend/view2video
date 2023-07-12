//
//  ShareSheet.swift
//
//
//  Created by dl on 19/11/2021.
//

import SwiftUI
import AVKit


import UIKit

 struct ShareVideoSheet: View {
    @Environment(\.presentationMode) var presentationMode
     @State private var showShareSheet = false
     var outputVideo: OutputVideo?
     
    @State private var showVideo = true
    @State private var startValue = 0.0
    @State private var endValue = 0.0
   
   
     @State var title =  ""
     @State var text = ""
     @State var currentImg = ""
//    var credit = ""
    var audio_time = 0

     @State private var output_url : URL?
    
    
   
    var screenWidth = UIScreen.main.bounds.width - 30
    
    @State var width : CGFloat = 0 //new
    @State var width1 : CGFloat = 30 //new
     var totalWidth = UIScreen.main.bounds.width - 60 // new
     
     
    @State var trimStart : CGFloat = 0
    @State var trimEnd : CGFloat = 68 //was 240

     @State var resizedWidth: CGFloat?
     let minWidth: CGFloat = 100
    @State var neWidth: CGFloat?
     
     
    var videoAudioDuration = 120

    var trimmedAudioUrl : URL?

    

    

    

    var imageTextBackground: some View {
          
       
        ZStack {
           
                // 3
              
            Image(currentImg)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .opacity(0.4)
            Rectangle()

               
                .opacity(0.25)
                .ignoresSafeArea()

            
            VStack( alignment: .leading){
            Spacer()
            Spacer()
                
            Text(title)
                .foregroundColor(.black)
                .font(.system(size: 22))
                .fontWeight(.medium)
                .padding(10)
                .multilineTextAlignment(.center)
                //.foregroundStyle(.thickMaterial)
                .background(Color.white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius:4))
                .padding(.horizontal, 20)
                
                
            Text(text)
                .lineLimit(nil)
                .lineSpacing(8)
                .foregroundColor(.black)
                .font(.system(size: 20))
                .padding(10)
               // .foregroundStyle(.ultraThickMaterial)
                .background(Color.white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius:4))
                .padding(.horizontal, 20)
           Spacer()
              
          
        
                
                
               Spacer()
               
             
            }
        }
            

       }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top){
             
                
            imageTextBackground
                   
             // RangeSlider
                    
              
             
            }.padding(.top, 40)//.overlay(RangeSlider, alignment: .bottom)
            .sheet(isPresented: $showShareSheet) {
       
               let video2share = "temp.mov"
                if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                                   
                      let videoURL = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(video2share)
                    let activityItems: [Any] = [videoURL, title]
                ShareSheet(activityItems: activityItems)
                }
              
            }

            .navigationBarItems(
              leading: Button(NSLocalizedString("cancel", comment: ""), action: dismiss),
              trailing: Button(
                NSLocalizedString("share", comment: "") , action: share))
        }.onAppear(perform: {

            self.showShareSheet = false

          
        }
        )
        
      
   }
    

    func dismiss() {
      presentationMode.wrappedValue.dismiss()
    }
    

     
    func share(){
        print("ShareVideoSheet:: sharing...start")
        //1. generate img from view
        let image = imageTextBackground.snapshot()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        guard let audioPath = Bundle.main.url(forResource: "1", withExtension:  "mp3")
        else {
            
            print("file not found")
            return }
        //.userDomainMask).first?.appendingPathComponent("\(note.id)\(note.time).mov")
        guard let internalMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("temp.mov") else
         {
              print("Error in generating video url ")
                return
        }
        print("Audio path: \(audioPath)\n video: \(internalMovieURL)")
       // let startTime = Double(note.time) // #review
       // startValue
        //2. createMovieWithSingleImageAndAudio
        createMovieWithSingleImageAndAudio(image: image, audioFileURL: audioPath, startTime: 0.0, assetExportPresetQuality: AVAssetExportPresetHighestQuality, outputVideoInternalURL: internalMovieURL)
         {
            error in
             if error != nil {
            print("Error in creating video with image and audio: \(error?.localizedDescription)  ")
            return
             }
             else
             {
                 print("createMovieWithSingleImageAndAudio 🎉")
                 self.output_url = internalMovieURL
                 print("Output_url is \(output_url?.path)")
                 self.showShareSheet = true

                 
             }
        }

      
        

        
        var pixelBuffer: CVPixelBuffer?

        
    }
     
   //static
     func writeSingleImageToMovie(image: UIImage, movieLength: TimeInterval, outputFileURL: URL, completion: @escaping (Error?) -> ())
     {
        print("writeSingleImageToMovie is called")
   
         print("Dimention of uiimage is \(image.size.width) x \(image.size.height)")
     
        do {
            let imageSize = image.size
            let videoWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: AVFileType.mov)
            let videoSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                                AVVideoWidthKey: imageSize.width, //was imageSize.width
                                                AVVideoHeightKey: imageSize.height] //was imageSize.height
            
          //  let videoSettings = AVOutputSettingsAssistant(preset: .preset1920x1080)?.videoSettings
            
            print("Image size \(imageSize.width) X \(imageSize.height)")
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
            
            if !videoWriter.canAdd(videoWriterInput) { throw NSError() }
            videoWriterInput.expectsMediaDataInRealTime = true
            videoWriter.add(videoWriterInput)
            
            videoWriter.startWriting()
            let timeScale: Int32 = 4 // 600 recommended in CMTime for movies.
            let halfMovieLength = Float64(movieLength/2.0) // videoWriter assumes frame lengths are equal.
            let startFrameTime = CMTimeMake(value: 0, timescale: timeScale)//CMTimeMake(value: Int64(note.time), timescale: timeScale)
         
            
            let endFrameTime = CMTimeMakeWithSeconds(Double(60), preferredTimescale: timeScale) //note.time +
                                                  
            videoWriter.startSession(atSourceTime: startFrameTime)
          
         
            
        guard let cgImage = image.cgImage else { throw NSError() }
             

   let buffer: CVPixelBuffer = try CGImage.pixelBuffer(fromImage: cgImage, size: imageSize)

            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: startFrameTime)
            while !adaptor.assetWriterInput.isReadyForMoreMediaData { usleep(10) }
            adaptor.append(buffer, withPresentationTime: endFrameTime)
            
            videoWriterInput.markAsFinished()
            videoWriter.finishWriting
            {
                completion(videoWriter.error)
            }
            
        } catch {
            print("CATCH Error in writeSingleImageToMovie")
            completion(error)
        }
}
    //static
     func addAudioToMovie(audioAsset: AVURLAsset, inputVideoAsset: AVURLAsset, outputVideoFileURL: URL, quality: String, startTime: Double, completion: @escaping (Error?) -> ())
     {
         print("addAudioToMovie is called: audioAsset duration: \(audioAsset.duration)")
        do {
            let composition = AVMutableComposition()
            
            guard let videoAssetTrack = inputVideoAsset.tracks(withMediaType: AVMediaType.video).first else { throw NSError() }
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: inputVideoAsset.duration), of: videoAssetTrack, at: CMTime.zero)
            
            let audioStartTime = CMTime.zero

            guard let audioAssetTrack = audioAsset.tracks(withMediaType: AVMediaType.audio).first else {  print("error: audioAssetTrack")
                throw NSError()
                 }
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: audioAsset.duration), of: audioAssetTrack, at: audioStartTime)

            
            guard let assetExport = AVAssetExportSession(asset: composition, presetName: quality) else { throw NSError()}
            assetExport.outputFileType = AVFileType.mp4
            assetExport.outputURL = outputVideoFileURL
            
            assetExport.exportAsynchronously {
                completion(assetExport.error)
            }
        } catch {
            print("catch Error in addAudioToMovie")
            completion(error)
        }
    }
    
     func createMovieWithSingleImageAndAudio(image: UIImage, audioFileURL: URL, startTime: Double, assetExportPresetQuality: String, outputVideoInternalURL: URL, completion: @escaping (Error?) -> ())
     {
       print("createMovieWithSingleImageAndAudio is called")
         print("- outputVideoFileURL : \(outputVideoInternalURL)")
         
         removeFile(at: outputVideoInternalURL)
         
         var audioAsset = AVURLAsset(url: audioFileURL)

         
         let videoOnlyURL = outputVideoInternalURL.appendingPathExtension("tmp.mov")
        removeFile(at: videoOnlyURL)
         // MARK: 1- trim audio
         let endTime = startValue + 120.0
         print("1st step trim audio from \(startValue) to \(endTime)")
         trimAudio(asset: audioAsset, startTime: startValue , stopTime: endTime) { trimmedAudioUrl in
              
             audioAsset = AVURLAsset(url: trimmedAudioUrl)

             let length =  TimeInterval((endTime - startTime))
             print("Audio duration is \(length)")
           
             // MARK: 2- generate video with the image
             self.writeSingleImageToMovie(image: image, movieLength: length, outputFileURL: videoOnlyURL) { (error: Error?) in
                 if let error = error
                 {
                     print("Error in writeSingleImageToMovie")
                     completion(error)
                     return
                 }
                 else {
                     
                     ////
                     if FileManager.default.fileExists(atPath: videoOnlyURL.path){
                    let  videoAsset = AVURLAsset(url: videoOnlyURL)
                    self.addAudioToMovie(audioAsset: audioAsset, inputVideoAsset: videoAsset, outputVideoFileURL: outputVideoInternalURL, quality: AVAssetExportPresetHighestQuality, startTime: startValue)
                         {
                     (error: Error?) in
               
                     print("adding audio is Completed let see if there is error")
                     completion(error)
                 }
                         print("Finished video location: \(outputVideoInternalURL)")
                         
         
                                  let outputVideo = OutputVideo(url: outputVideoInternalURL)
                         outputVideo.url = outputVideoInternalURL
//                                 // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//
                                  outputVideo.saveVideo()
                     }
                     else {
                         print("no video at the video url")
                     
                     
                  ///
                 }
                 
                 
                 
                 
                 
             }
             
             }
 
      
         }
     


    

     func trimAudio(asset: AVAsset, startTime: Double, stopTime: Double, finished:@escaping (URL) -> ())
     {
            print("Trim Audio  - NEW function")
             let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith:asset)

             if compatiblePresets.contains(AVAssetExportPresetMediumQuality) {

             guard let exportSession = AVAssetExportSession(asset: asset,
             presetName: AVAssetExportPresetAppleM4A) else{return}

             // Creating new output File url and removing it if already exists.
             let furl = createUrlInAppDD(fileName: "trimmed_Audio.m4a") //Custom Function
          
                removeFile(at: furl)

             exportSession.outputURL = furl
             exportSession.outputFileType = AVFileType.m4a

             let start: CMTime = CMTimeMakeWithSeconds(startTime, preferredTimescale: asset.duration.timescale)
             let stop: CMTime = CMTimeMakeWithSeconds(stopTime, preferredTimescale: asset.duration.timescale)
             let range: CMTimeRange = CMTimeRangeFromTimeToTime(start: start, end: stop)
             exportSession.timeRange = range
                 
                 

             exportSession.exportAsynchronously(completionHandler: {

                 switch exportSession.status {
                 case .failed:
                     print("Export failed: \(exportSession.error!.localizedDescription)")
                 case .cancelled:
                     print("Export canceled")
                 default:
                     print("Successfully trimmed audio")
                     DispatchQueue.main.async(execute: {
                         finished(furl)
                     })
                 }
             })
         }
     }
     
     }
     func createUrlInAppDD(fileName: String) -> URL  {
         let trimmedAudioFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.deletingPathExtension().appendingPathComponent("\(fileName)_trimmed.m4a")
         return trimmedAudioFileUrl! //review
     }


     func removeFile(at: URL?){
         //delete any old temp file
       
         guard let _url = at else { return}
         if FileManager.default.fileExists(atPath: _url.path) {
         do {
             print("Function Remove file at \(_url)")
             try FileManager.default.removeItem(atPath: _url.path)
         } catch {
           print("Could not remove file at \(_url)\n cause: \(error.localizedDescription)")
         }
         }
     }
}

     
     
     
class OutputVideo{
    var url: URL?
    
    init(url: URL){
        self.url = url
    }
    
    // MARK: save generated video to PhotoAlbum
    func saveVideo(){
        print("saving viedo at...")
        guard let _url = url else { return}
        print(_url)
        UISaveVideoAtPathToSavedPhotosAlbum(_url.relativePath, nil, #selector(saveVideoCompleted),nil)
    }
    @objc func saveVideoCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
           print("Save finished!")

       

        
        
          // deleteTemproryVideo()
       }
    func deleteTemproryVideo(){
        //delete any old temp file
        guard let _url = url else { return}
        do {
          try FileManager.default.removeItem(at: _url)
        } catch {
          print("Could not remove file at \(_url)\n cause: \(error.localizedDescription)")
        }
    }
}


//struct shareSheet_Previews: PreviewProvider {
//    static var previews: some View {
//      //  ShareSheet()
//    }
//}
