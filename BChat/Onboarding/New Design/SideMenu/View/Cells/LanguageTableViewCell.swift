// Copyright © 2026 Beldex International Limited OU. All rights reserved.

import UIKit

final class LanguageTableViewCell: UITableViewCell {

    static let identifier = "LanguageTableViewCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.cellGroundColor2
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        return view
    }()

    private let radioOuterView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8.5
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.titleColor3.cgColor
        view.backgroundColor = .clear
        return view
    }()

    private let radioInnerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5.5
        view.backgroundColor = Colors.bothGreenColor
        view.isHidden = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.titleColor3
        label.font = Fonts.regularOpenSans(ofSize: 16)
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = Colors.mainBackGroundColor2
        selectionStyle = .none

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {

        contentView.addSubview(containerView)
        containerView.addSubview(radioOuterView)
        radioOuterView.addSubview(radioInnerView)
        containerView.addSubview(titleLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        radioOuterView.translatesAutoresizingMaskIntoConstraints = false
        radioInnerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 60),

            // Radio Outer
            radioOuterView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            radioOuterView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            radioOuterView.widthAnchor.constraint(equalToConstant: 17),
            radioOuterView.heightAnchor.constraint(equalToConstant: 17),

            // Radio Inner
            radioInnerView.centerXAnchor.constraint(equalTo: radioOuterView.centerXAnchor),
            radioInnerView.centerYAnchor.constraint(equalTo: radioOuterView.centerYAnchor),
            radioInnerView.widthAnchor.constraint(equalToConstant: 11),
            radioInnerView.heightAnchor.constraint(equalToConstant: 11),

            // Label
            titleLabel.leadingAnchor.constraint(equalTo: radioOuterView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Configure

    func configure(with title: String, isSelected: Bool) {

        titleLabel.text = title

        if isSelected {
            containerView.layer.borderColor = Colors.bothGreenColor.cgColor
            radioOuterView.layer.borderColor = Colors.bothGreenColor.cgColor
            radioInnerView.isHidden = false
        } else {
            containerView.layer.borderColor = UIColor.clear.cgColor
            radioOuterView.layer.borderColor = Colors.titleColor.cgColor
            radioInnerView.isHidden = true
        }
    }
}
