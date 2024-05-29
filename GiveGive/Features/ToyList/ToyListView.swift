//
//  ToyListView.swift
//  GiveGive
//
//  Created by Joanne Yager on 2023-11-06.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ToyListView: View {

    // A view should never know about databases, this is for viewmodel or further back
    @EnvironmentObject var dbManager: DatabaseManager
    @State var isDismissed: Bool = false
    
    var body: some View {
        ToyGridView(isDismissed: $isDismissed)
            .onAppear {
                dbManager.listenToFirestore()
            }
    }
    
}

struct ToyGridView: View {
    
    @EnvironmentObject var dbManager: DatabaseManager

    @Binding var isDismissed: Bool
    
    var body: some View {
        
        ScrollView{
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2), spacing: 10) {
                ForEach(dbManager.currentToyList) { item in
                    
                    ToyThumbnailView(toy: item, isDismissed: $isDismissed)
                    .padding(5)
                }
            }
        }
        .padding()
    }
}

struct ToyThumbnailView: View {
    
    @EnvironmentObject var dbManager: DatabaseManager

    var toy: Toy
    @State private var url: URL? = nil
    @Binding var isDismissed: Bool
    
    var body: some View {
        // This way of doing navigation like this is very memory heavy. 
        // Here are som alternatives: https://blorenzop.medium.com/routing-navigation-in-swiftui-f1f8ff818937
        NavigationLink {
            ToyProfileView(vm: ToyProfileViewModel(toy: toy), dismissView: $isDismissed)
        } label: {
            ZStack {
                Rectangle()
                    .fill(.black)
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fit)
                
                if let urlString = toy.images.first?.url, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    // UI should not trigger database actions directly
                    dbManager.deleteItem(toy: toy)
                } label: {
                    Text("x")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                        .padding(4)
                        .background(Circle().fill(Color("BackgroundColor")))
                        .opacity(0.8)
                        .shadow(radius: 2)
                       
                }

            }
        }
    }
}
