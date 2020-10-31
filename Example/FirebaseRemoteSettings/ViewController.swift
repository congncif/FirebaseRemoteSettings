//
//  ViewController.swift
//  FirebaseRemoteSettings
//
//  Created by NGUYEN CHI CONG on 10/31/2020.
//  Copyright (c) 2020 NGUYEN CHI CONG. All rights reserved.
//

import CoreRemoteSettings
import FirebaseRemoteSettings
import RxSwift
import UIKit

struct AppRemoteSettings {
    enum Keys: String {
        case minVersion = "min_version"
    }

    private let provider: RemoteSettingsProviding

    init(provider: RemoteSettingsProviding) {
        self.provider = provider
    }

    var minVersion: Observable<String> {
        provider.rx.value.map {
            $0.settingsValue(for: Keys.minVersion.rawValue).string
        }
    }
}

class ViewController: UIViewController {
    lazy var remoteSettings = AppRemoteSettings(provider: FirebaseRemoteSettings.shared)

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        remoteSettings.minVersion
            .subscribe(onNext: {
                print("1/ Remote settings value: \($0)")
            }, onDisposed: {
                print("1/ Done")
            })
            .disposed(by: disposeBag)
    }

    @IBAction private func refreshButtonDidTap() {
        remoteSettings.minVersion
            .distinctUntilChanged()
            .subscribe(onNext: {
                print("2/ Remote settings value: \($0)")
            }, onDisposed: {
                print("2/ Done")
            })
            .disposed(by: disposeBag)
    }
}
