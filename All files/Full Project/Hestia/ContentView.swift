//
//  ContentView.swift
//  Hestia
//
//  Created by Yuri Hoashi on 1/3/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 70) {
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "house")
                        .foregroundColor(selectedTab == 0 ? Color("myOrange") : Color("myDarkGray"))
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    if selectedTab == 0 {
                        Circle() // Dot indicator
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                    }
                }
                
            }
            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(selectedTab == 1 ? Color("myOrange") : Color("myDarkGray"))
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    if selectedTab == 1 {
                        Circle() // Dot indicator
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                    }
                }
            }
            Button(action: { selectedTab = 2 }) {
                VStack {
                    Image(systemName: "person")
                        .foregroundColor(selectedTab == 2 ? Color("myOrange") : Color("myDarkGray"))
                        .font(.system(size: 29))
                        .fontWeight(.bold)
                    if selectedTab == 2 {
                        Circle() // Dot indicator
                            .fill(Color.orange)
                            .frame(width: 6, height: 6)
                            .padding(.top, 5)
                    }
                }
            }
        }
        .padding()
        .background(Color("myLightGray"))
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    
    var body: some View {
        VStack {
            Spacer()
            if selectedTab == 0 {
                predictView()
            } else if selectedTab == 1 {
                chatView()
            } else {
                profileView()
            }
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(Color("myLightGray"))
        .ignoresSafeArea()

    }
}
#Preview {
    ContentView()
}
