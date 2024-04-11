//
//  MessageCell.swift
//  Chat
//
//  Created by Dmitry Grigoryev on 09.04.2024.
//

import UIKit

class MessageCell: UICollectionViewCell {

	static let reuseIdentifier = String(describing: MessageCell.self)

	private var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .black
		label.numberOfLines = 0

		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		var targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
		if let superview {
			targetSize.width = superview.frame.width
		}
				layoutAttributes.frame.size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
			return layoutAttributes
	}
}

extension MessageCell {
	func updateTitle(_ title: String?) {
		titleLabel.text = title
//		titleLabel.sizeToFit()
	}
}
private extension MessageCell {

	func setupUI() {

		addTitleLabel()
	}

	func addTitleLabel() {

		contentView.backgroundColor = .white
		contentView.layer.borderColor = UIColor.gray.cgColor
		contentView.layer.borderWidth = 1
		contentView.layer.cornerRadius = 25

		contentView.addSubview(titleLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
			titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
			titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
		])
	}
}
