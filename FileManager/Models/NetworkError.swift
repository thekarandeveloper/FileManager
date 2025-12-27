//
//  NetworkError.swift
//  FileManager
//
//  Created by swipe mac on 27/12/25.
//


import Foundation

enum NetworkError: Equatable {
    case noInternet
    case serverError
    case timeout
    case unknown(String)
    
    var title: String {
        switch self {
        case .noInternet: return "No Internet Connection"
        case .serverError: return "Server Error"
        case .timeout: return "Request Timeout"
        case .unknown: return "Something Went Wrong"
        }
    }
    
    var message: String {
        switch self {
        case .noInternet: return "Please check your internet connection and try again."
        case .serverError: return "The server is not responding. Please try again later."
        case .timeout: return "The request took too long. Please try again."
        case .unknown(let msg): return msg
        }
    }
}
