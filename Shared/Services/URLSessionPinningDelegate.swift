//
//  URLSessionPinningDelegate.swift
//  PolyglotFlashcards
//
//  Created by Igor Kim on 12.12.21.
//

import Foundation

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    var resourceName: String
    
    init(forResource resourceName: String) {
        self.resourceName = resourceName
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            guard let serverTrust = challenge.protectionSpace.serverTrust,
                  SecTrustEvaluateWithError(serverTrust, nil) else {
                return completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
            
            if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                let serverCertificateData = SecCertificateCopyData(serverCertificate)
                let data = CFDataGetBytePtr(serverCertificateData);
                let size = CFDataGetLength(serverCertificateData);
                let cert1 = NSData(bytes: data, length: size)
                let file_der = Bundle.main.path(forResource: resourceName, ofType: "der")
                
                if let file = file_der {
                    if let cert2 = NSData(contentsOfFile: file) {
                        if cert1.isEqual(to: cert2 as Data) {
                            return completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                        }
                    }
                }
            }
            
        }
        return completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        
    }
}
