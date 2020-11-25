//
//  FirebaseRemoteSettings.swift
//  SDK
//
//  Created by NGUYEN CHI CONG on 10/28/20.
//

import CoreRemoteSettings
import FirebaseRemoteConfig
import Foundation

extension RemoteConfigValue: RemoteSettingsValue {
    public var data: Data? {
        dataValue
    }
}

extension RemoteConfig: RemoteSettings {
    public func settingsValue(for key: String) -> RemoteSettingsValue {
        configValue(forKey: key)
    }
}

public final class FirebaseRemoteSettings: RemoteSettingsProviding {
    private init() {}

    public var minimumFetchInterval: TimeInterval = 1800
    public var fetchTimeout: TimeInterval = 30

    public func get() -> RemoteSettings { return remoteConfig }

    public func fetch(completion: @escaping (RemoteSettings) -> Void) {
        operationQueue.sync {
            completions.append(completion)
            
            if !isFetching {
                isFetching = true

                if isFetchEnabled {
                    perfromFetch(completion: { [unowned self] config in
                        self.result = config
                        self.isFetching = false
                    })
                } else {
                    result = remoteConfig
                    isFetching = false
                }
            }
        }
    }

    private var isFetchEnabled: Bool {
        guard let lastFetchedTime = remoteConfig.lastFetchTime else {
            return true
        }
        return Date().timeIntervalSince1970 - lastFetchedTime.timeIntervalSince1970 > minimumFetchInterval
    }

    private func perfromFetch(completion: @escaping (RemoteSettings) -> Void) {
        remoteConfig.ensureInitialized { [unowned self] error in
            if let error = error {
                #if DEBUG
                print("[Remote Config] init error: \(error)")
                completion(remoteConfig)
                #endif
            } else {
                self.remoteConfig.fetch(withExpirationDuration: 0) { [unowned remoteConfig] status, fetchError in
                    switch status {
                    case .success:
                        remoteConfig.activate { [unowned remoteConfig] changed, activeError in
                            #if DEBUG
                            if let error = activeError {
                                print("\(String(describing: Self.self)) - \(#function): \(String(describing: error))")
                            }
                            if !changed {
                                print("\(String(describing: Self.self)) - \(#function): Nothing changes")
                            }
                            #endif
                            completion(remoteConfig)
                        }
                    default:
                        #if DEBUG
                        if let error = fetchError {
                            print("\(String(describing: Self.self)) - \(#function): \(String(describing: error))")
                        }
                        #endif
                        completion(remoteConfig)
                    }
                }
            }
        }
    }

    // MARK: - Privates

    private var remoteConfig: RemoteConfig {
        let config = RemoteConfig.remoteConfig()
        let settings = config.configSettings
        settings.minimumFetchInterval = minimumFetchInterval
        settings.fetchTimeout = fetchTimeout
        config.configSettings = settings
        return config
    }

    private lazy var result: RemoteSettings = get() {
        didSet {
            report(result: result)
        }
    }

    private lazy var operationQueue = DispatchQueue(label: "remote-settings.sync", qos: .background)

    private lazy var completions: [(RemoteSettings) -> Void] = []
    private lazy var isFetching: Bool = false

    private func report(result: RemoteSettings) {
        completions.forEach { $0(result) }
        completions = []
    }
}

extension FirebaseRemoteSettings {
    public static let shared = FirebaseRemoteSettings()
}
