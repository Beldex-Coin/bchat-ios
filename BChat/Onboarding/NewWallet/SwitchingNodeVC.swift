// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class SwitchingNodeVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.popUpBackgroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor.cgColor
        return stackView
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Switching Node, Please wait.."
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.center = view.center
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = Colors.cancelButtonBackgroundColor
        progressView.tintColor = Colors.greenColor
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.refreshNodePopUpBackgroundColor
        view.addSubview(backGroundView)
        backGroundView.addSubViews(discriptionLabel, progressView)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            discriptionLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 21),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 50),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -50),
            progressView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 13),
            progressView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -23),
            progressView.heightAnchor.constraint(equalToConstant: 6)
        ])
        
        // Start your progress asynchronously
        DispatchQueue.global(qos: .background).async {
            var progress: Float = 0.0
            repeat {
                progress += 0.1
                Thread.sleep(forTimeInterval: 0.25)
                DispatchQueue.main.async {
                    self.progressView.setProgress(progress, animated: true)
                    if progress >= 1.0 {
                        // Dismiss the view controller once progress completes
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            } while progress < 1.0
        }
            
        
    }
    
}
