//
//  QRView.swift
//  Astro
//
//  Created by Joanne Yager on 2023-10-05.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRView: View {
    
    @State var toy: Toy
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        HStack {
            if let id = toy.id {
                Image(uiImage: generateQRCode(from: id))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading) {
                    Text("Toy id \(id)")
                    // .font(Font.custom("WorkSans-Bold", size: 32))
                    //.fontWeight(.bold)
                }
                .padding(.horizontal)
                .onAppear {
                    print("toy id \(id)")
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color("BackgroundColor"))
        .cornerRadius(15.0)
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    QRView(toy: Toy())
}
