//
//  ChatDateSection.swift
//
//

import UIKit

// MARK: - ChatDateSection

final class ChatDateSection: UICollectionReusableView {

	static let reuseIdentifier = String(describing: ChatDateSection.self)

	private var mainStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.backgroundColor = .orange
		stackView.axis = .horizontal
		stackView.distribution = .fill
		stackView.alignment = .center
		stackView.spacing = 8

		return stackView
	}()

	private var separator: UIView {
		let view = UIView()
		view.backgroundColor = .gray

		return view
	}

	private lazy var dateLabel: PaddingLabel = {
		let label = PaddingLabel()
		label.layer.cornerRadius = 13
		label.clipsToBounds = true
		label.backgroundColor = .white
		label.numberOfLines = 1

		label.textAlignment = .center

		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		setup()
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension ChatDateSection {

	func updateTitle(_ title: String) {
		dateLabel.text = title
	}
}

private extension ChatDateSection {

	func setup() {

//		let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 42)
//		heightConstraint.priority = .defaultLow
//		heightConstraint.isActive = true

		setupSubviews()
	}

	func setupSubviews() {
		addSubview(mainStackView)

		mainStackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			mainStackView.topAnchor.constraint(equalTo: topAnchor),
			mainStackView.leftAnchor.constraint(equalTo: leftAnchor),
			mainStackView.rightAnchor.constraint(equalTo: rightAnchor),
			mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
		let leftSeparator = separator
		let rightSeparator = separator

		mainStackView.addArrangedSubview(leftSeparator)
		mainStackView.addArrangedSubview(dateLabel)
		mainStackView.addArrangedSubview(rightSeparator)

		NSLayoutConstraint.activate([
			leftSeparator.widthAnchor.constraint(equalTo: rightSeparator.widthAnchor),
			leftSeparator.heightAnchor.constraint(equalToConstant: 1),
			rightSeparator.heightAnchor.constraint(equalToConstant: 1)
		])
	}
}

private extension ChatDateSection {

	class PaddingLabel: UILabel {

		var topInset: CGFloat = 3.0
		var bottomInset: CGFloat = 3.0
		var leftInset: CGFloat = 16.0
		var rightInset: CGFloat = 16.0

		override func drawText(in rect: CGRect) {
			let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
			super.drawText(in: rect.inset(by: insets))
		}

		override var intrinsicContentSize: CGSize {
			let size = super.intrinsicContentSize
			return CGSize(width: size.width + leftInset + rightInset,
						  height: size.height + topInset + bottomInset)
		}
	}
}
