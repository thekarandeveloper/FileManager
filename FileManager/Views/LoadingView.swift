//
//  LoadingView.swift
//  FileManager
//
//  Created by swipe mac on 27/12/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .green, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotation))
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(scale)
                
                VStack(spacing: 8) {
                    Text("Drive Manager")
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text("Loading...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1
            }
        }
    }
}
