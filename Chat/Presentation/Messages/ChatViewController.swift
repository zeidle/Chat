//
//  ChatController.swift
//

import UIKit

// MARK: - ChatDisplayLogic

protocol ChatDisplayLogic: AnyObject where Self: UIViewController {

	var interactor: ChatBusinessLogic? { get }
	var router: (ChatRoutingLogic & ChatDataPassing)? { get }

	func setup()
	func reloadMessages(with model: ChatModel.FetchMessage.ViewModel)
	func addOlderMessages(with model: ChatModel.FetchMessage.ViewModel)
	func showRefreshControl()
	func hideRefreshControl()
}


// MARK: - ChatPresener

class ChatViewController: UIViewController {

	typealias MessagesGroup = ChatModel.MessagesGroup
	// MARK: - Internal properties

	var interactor: ChatBusinessLogic?
	var router: (ChatRoutingLogic & ChatDataPassing)?

	// MARK: - private properties
	private var isRefreshing: Bool = false
	private var messagesContentSize: CGSize = .zero

	private var flowLayout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//		layout.itemSize = UICollectionViewFlowLayout.automaticSize
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = 4

		return layout
	}()
	private var messagesGroups: [MessagesGroup] = []
	private lazy var collectionView: UICollectionView = {


		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseIdentifier)
		collectionView.register(ChatDateSection.self,
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
								withReuseIdentifier: ChatDateSection.reuseIdentifier)
		collectionView.allowsSelection = false
		collectionView.keyboardDismissMode = .onDrag

		collectionView.refreshControl = refreshControl
		collectionView.refreshControl?.layer.zPosition = -1

		return collectionView
	}()

	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
		refreshControl.tintColor = .blue

		return refreshControl
	}()

	private lazy var inputBarView: InputBarView = {
		let inputBarView = InputBarView()
		inputBarView.delegate = self

		return inputBarView
	}()

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		interactor?.viewDidLoad()

		//   Эта строка предотвращает баг связанный с некорректным отображением цвета в refreshControl (https://stackoverflow.com/a/31224299))
		self.collectionView.contentOffset = CGPoint(x:0, y:-self.refreshControl.frame.size.height)
	}


	deinit {
		print("-- \(String(describing: Self.self)) deinit")
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - ChatDisplayLogic

extension ChatViewController: ChatDisplayLogic {

	func setup() {
		setupUI()
		setupLocalize()
		setupAccessibilityIdentifier()
		setupAccessibilityLabel()
		setupObservers()
	}

	func setupObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc func keyboardWillShow(notification: Notification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0 {
				self.view.frame.origin.y -= keyboardSize.height
			}
		}

	}

	@objc func keyboardWillHide(notification: Notification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y != 0 {
				self.view.frame.origin.y += keyboardSize.height
			}
		}
	}

	func setupUI() {
		view.backgroundColor = .white

		setupTableView()
		setupInputBarView()
	}

	func setupTableView() {
		view.addSubview(collectionView)

		collectionView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
			collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
		])
	}

	func setupInputBarView() {
		view.addSubview(inputBarView)

		inputBarView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			inputBarView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
			inputBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
			inputBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
			inputBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
		])
	}

	func reloadMessages(with model: ChatModel.FetchMessage.ViewModel) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			self.messagesGroups = model.messageGroups
			self.collectionView.reloadData()
			self.collectionView.layoutIfNeeded()

			let lastSection = collectionView.numberOfSections - 1
			let lastRow = collectionView.numberOfItems(inSection: lastSection) - 1

			guard lastSection >= 0, lastRow >= 0 else { return }

			let indexPath = IndexPath(row: lastRow, section: lastSection)

			self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
		}
	}

	func addOlderMessages(with model: ChatModel.FetchMessage.ViewModel) {

		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			let mergedMessagesGroups = messagesGroups.merge(model.messageGroups).sorted()

			messagesGroups = mergedMessagesGroups

			let beforeContentSize = self.collectionView.contentSize
			let beforeContentOffset = self.collectionView.contentOffset

			self.collectionView.reloadData()
			self.collectionView.layoutIfNeeded()

			let afterContentSize = self.collectionView.contentSize
			let afterContentOffset = self.collectionView.contentOffset

			print("beforeSize: \(beforeContentSize.height)")
			print("afterSize: \(afterContentSize.height)")
			print("beforeContentOffset: \(beforeContentOffset)")
			print("afterContentOffset: \(afterContentOffset)")

			collectionView.contentOffset.y = afterContentSize.height - beforeContentSize.height + beforeContentOffset.y
		}
	}

	func showRefreshControl() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			self.isRefreshing = true
			self.refreshControl.beginRefreshing()
		}
	}

	func hideRefreshControl() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			self.isRefreshing = false
			self.refreshControl.endRefreshing()
		}
	}
}

// MARK: - Private ChatViewController
private extension ChatViewController {

	func setupLocalize() {
		// TODO: - some actions
	}

	func setupAccessibilityIdentifier() {
		// TODO: - some actions
	}

	func setupAccessibilityLabel() {
		// TODO: - some actions
	}
}

private extension ChatViewController {

	@objc func didPullToRefresh() {
		refreshControl.endRefreshing()
	}
}

// MARK: - TableViewDelegate & TableViewSource

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		messagesGroups[section].messages.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let section = indexPath.section
		let row = indexPath.row
		let messageGroup = messagesGroups[section]
		let message = messageGroup.messages[row]

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.reuseIdentifier, for: indexPath)

		guard let cell = cell as? MessageCell else { return .init() }

		cell.updateTitle(message.text)

		return cell
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ChatDateSection.reuseIdentifier, for: indexPath)

		guard let sectionView = sectionView as? ChatDateSection else { return .init() }

		let date = messagesGroups[indexPath.section].date
		sectionView.updateTitle(date)

		return sectionView
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		messagesGroups.count
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		guard !isRefreshing else { return }

		let visibleSize = scrollView.visibleSize
		let contentOffset = scrollView.contentOffset

		let request = ChatModel.TableMessagesInfo.Request(visibleSize: visibleSize, contentOffset: contentOffset)

		interactor?.messagesDidScroll(request: request)

	}
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {

	func collectionView(
	  _ collectionView: UICollectionView,
	  layout collectionViewLayout: UICollectionViewLayout,
	  referenceSizeForHeaderInSection section: Int
	) -> CGSize {
		let width = Int(collectionView.frame.width)
		let height = 42

		return CGSize(width: width, height: height)
	}

}

// MARK: - InputBarDelegate

extension ChatViewController: InputBarViewDelegate {

	func inputBar(_ inputBar: InputBarView, didPressSendButtonWith text: String) {

	}

	func inputBar(_ inputBar: InputBarView, didChangeIntrinsicContentFrom size: CGSize) {

		let offsetY = inputBar.frame.height - size.height
		let contentHeight = collectionView.contentSize.height
		let visibleContentHeight = collectionView.visibleSize.height
		let contentOffsetY = collectionView.contentOffset.y

		let didScrollToBottom = (contentHeight - visibleContentHeight) == contentOffsetY

		guard !didScrollToBottom else { return }

		collectionView.contentOffset.y += offsetY
	}

	func inputBar(_ inputBar: InputBarView, textViewTextDidChangeTo text: String) {}
}

final class CommentFlowLayout : UICollectionViewFlowLayout {

//	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//			let layoutAttributesObjects = super.layoutAttributesForElements(in: rect)?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
//			layoutAttributesObjects?.forEach({ layoutAttributes in
//				if layoutAttributes.representedElementCategory == .cell {
//					if let newFrame = layoutAttributesForItem(at: layoutAttributes.indexPath)?.frame {
//						layoutAttributes.frame = newFrame
//					}
//				}
//			})
//			return layoutAttributesObjects
//		}
//
//	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//		guard let collectionView = collectionView else { fatalError() }
//		guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
//			return nil
//		}
//
//		layoutAttributes.frame.origin.x = sectionInset.left
//		layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
//		return layoutAttributes
//	}
}
