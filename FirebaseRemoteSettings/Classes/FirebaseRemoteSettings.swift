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
    public static let shared = FirebaseRemoteSettings()

    var remoteConfig: RemoteConfig {
        let config = RemoteConfig.remoteConfig()
        let settings = config.configSettings
        settings.minimumFetchInterval = minimumFetchInterval
        settings.fetchTimeout = fetchTimeout
        config.configSettings = settings
        return config
    }

    public var minimumFetchInterval: TimeInterval = 0
    public var fetchTimeout: TimeInterval = 30

    private init() {}

    public func get() -> RemoteSettings { return remoteConfig }

    public func fetch(completion: @escaping (RemoteSettings) -> Void) {
        if isFetchEnabled {
            perfromFetch(completion: completion)
        } else {
            remoteConfig.ensureInitialized { [unowned remoteConfig] error in
                #if DEBUG
                if let error = error {
                    print("[Remote Config] init error: \(error)")
                }
                #endif
                completion(remoteConfig)
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
        remoteConfig.fetch(withExpirationDuration: 0) { [unowned remoteConfig] status, fetchError in
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
