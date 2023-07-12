//
//  ContentView.swift
//  image-text-video
//
//  Created by dl on 07/05/2023.
//

import SwiftUI

struct ContentView: View {
    let images = [1,2]
    let titles = ["Good Morning", "Good Evening"]
    let texts = ["Have a nice day!", "Good night!"]
    @State var currentImg = "1"
    @State private var shareIsPresented = false
    
    @State var title: String?
    @State var text: String?
    
    
    var body: some View {
        NavigationView {
        VStack {
            
            ScrollView(.horizontal, showsIndicators: true, content: {
                ScrollViewReader { value in
                    HStack {
                        ForEach(Array(images.enumerated()), id:\.element) {
                            idx, img in
                            Image(String(img)).resizable().aspectRatio(contentMode: .fill).frame(width: 160, height: 100, alignment:.center ).padding()
                            
                                .onTapGesture{
                                    // self.currentAlbum = album
                                    print("Image: \(img) ")
                                    self.currentImg = String(img)
                                    self.title = titles[idx]
                                    self.text = texts[idx]
                                    
                                }
                        }
                        
                    }.padding() }
                
                
            })
//            VStack{
//                ZStack{
//                    Image(currentImg)
//                        .resizable()
//                        .scaledToFill()
//                        .opacity(0.4)
//                        .edgesIgnoringSafeArea(.all)
//                    Text(title ?? titles[0])
//                        .font(.title)
//                        .lineSpacing(8)
//                        .foregroundColor(.black)
//                        .font(.system(size: 20))
//                        .padding(10)
//                    // .foregroundStyle(.ultraThickMaterial)
//                        .background(Color.white.opacity(0.25))
//                        .clipShape(RoundedRectangle(cornerRadius:4))
//
//
//
//
//                }
//            }
//            VStack{
                ZStack {
                    
                    // 3
                    
                    Image(self.currentImg)
                        .resizable()
                        .scaledToFill()
//                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    // .ignoresSafeArea()
                        .opacity(0.4)
                    Rectangle()
                    
                    
                        .opacity(0.25)
                    // .ignoresSafeArea()
                    // alignment: .leading
                    VStack(){
                        Spacer()
                        Spacer()
                        
                        Text(title ?? titles[0])
                            .foregroundColor(.black)
                            .font(.system(size: 22))
                            .fontWeight(.medium)
                            .padding(10)
                            .multilineTextAlignment(.center)
                        //.foregroundStyle(.thickMaterial)
                            .background(Color.white.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius:4))
                            .padding(.horizontal, 20)
                        
                        
                        Text(text ?? texts[0])
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
               // }
            
        }
            
        }.navigationBarItems(
          
            trailing: Button(
                NSLocalizedString("share", comment: "") , action: self.share)).foregroundColor(.brown)
                    
        
        .onAppear(){
           // self.title = "Good Morning"
            
        }
        
    }.sheet(isPresented: $shareIsPresented) {
        ShareVideoSheet( title: self.title ?? titles[0] , text: self.text ?? texts[0], currentImg: self.currentImg)
    }
        
     
}
    func share () {
        print("share")
        print("For share Title is \(self.title) text is \(self.text)")
        shareIsPresented.toggle()
  
    }
//    func dismiss() {
//      presentationMode.wrappedValue.dismiss()
//    }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
