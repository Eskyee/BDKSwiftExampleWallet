//
//  OnboardingViewModel.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/6/23.
//

import BitcoinDevKit
import Foundation
import SwiftUI

// Can't make @Observable yet
// https://developer.apple.com/forums/thread/731187
// Feature or Bug?
class OnboardingViewModel: ObservableObject {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @Published var networkColor = Color.gray
    @Published var onboardingViewError: BdkError?
    let bdkClient: BDKClient
    @Published var words: String = ""
    @Published var selectedNetwork: Network = .testnet {
        didSet {
            do {
                let networkString = selectedNetwork.description
                try KeyClient.live.saveNetwork(networkString)
                selectedURL = availableURLs.first ?? ""
                try KeyClient.live.saveEsploraURL(selectedURL)
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .InvalidNetwork(message: "Error Selecting Network")
                }
            }
        }
    }
    @Published var selectedURL: String = "" {
        didSet {
            do {
                try KeyClient.live.saveEsploraURL(selectedURL)
            } catch {
                DispatchQueue.main.async {
                    self.onboardingViewError = .Esplora(message: "Error Selecting Esplora")
                }
            }
        }
    }

    init(bdkClient: BDKClient = .live) {
        self.bdkClient = bdkClient
        do {
            if let networkString = try KeyClient.live.getNetwork() {
                self.selectedNetwork = Network(stringValue: networkString) ?? .testnet
            } else {
                self.selectedNetwork = .testnet
            }
            if let esploraURL = try KeyClient.live.getEsploraURL() {
                self.selectedURL = esploraURL
            } else {
                self.selectedURL = availableURLs.first ?? ""
            }
        } catch {
            DispatchQueue.main.async {
                self.onboardingViewError = .Esplora(message: "Error Selecting Esplora")
            }
        }
    }

    var availableURLs: [String] {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.Config.EsploraServerURLNetwork.Bitcoin.allValues
        case .testnet:
            return Constants.Config.EsploraServerURLNetwork.Testnet.allValues
        case .regtest:
            return Constants.Config.EsploraServerURLNetwork.Regtest.allValues
        case .signet:
            return Constants.Config.EsploraServerURLNetwork.Signet.allValues
        }
    }

    var buttonColor: Color {
        switch selectedNetwork {
        case .bitcoin:
            return Constants.BitcoinNetworkColor.bitcoin.color
        case .testnet:
            return Constants.BitcoinNetworkColor.testnet.color
        case .signet:
            return Constants.BitcoinNetworkColor.signet.color
        case .regtest:
            return Constants.BitcoinNetworkColor.regtest.color
        }
    }

    func createWallet() {
        do {
            try bdkClient.createWallet(words)
            isOnboarding = false
        } catch let error as WalletError {
            print("createWallet - Wallet Error: \(error.localizedDescription)")
        } catch {
            print("createWallet - Undefined Error: \(error.localizedDescription)")
        }
    }

}
