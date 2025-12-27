//
//  ErrorView.swift
//  FileManager
//
//  Created by swipe mac on 27/12/25.
//


import SwiftUI

struct ErrorView: View {
    let error: NetworkError
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.7))
            
            Text(error.title)
                .font(.system(size: 20, weight: .semibold))
            
            Text(error.message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onRetry) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var iconName: String {
        switch error {
        case .noInternet: return "wifi.slash"
        case .serverError: return "server.rack"
        case .timeout: return "clock.badge.exclamationmark"
        case .unknown: return "exclamationmark.triangle"
        }
    }
}