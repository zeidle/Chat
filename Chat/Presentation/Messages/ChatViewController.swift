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
	private let cellId = "cellId"
	private var messagesGroups: [MessagesGroup] = []
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .grouped)

		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .interactive
		tableView.sectionHeaderTopPadding = .zero

		tableView.refreshControl = refreshControl
		tableView.refreshControl?.layer.zPosition = -1
		tableView.sectionHeaderTopPadding = 0
		tableView.sectionFooterHeight = 0
		tableView.estimatedRowHeight = 10
		tableView.estimatedSectionHeaderHeight = 42
//		tableView.estimatedSectionFooterHeight = 500

		return tableView
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
		self.tableView.contentOffset = CGPoint(x:0, y:-self.refreshControl.frame.size.height)
	}

	deinit {
		print("-- \(String(describing: Self.self)) deinit")
	}
}

// MARK: - ChatDisplayLogic

extension ChatViewController: ChatDisplayLogic {

	func setup() {
		setupUI()
		setupLocalize()
		setupAccessibilityIdentifier()
		setupAccessibilityLabel()
	}

	func setupUI() {
		view.backgroundColor = .white

		setupTableView()
		setupInputBarView()
	}

	func setupTableView() {
		view.addSubview(tableView)

		tableView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
			tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
		])
	}

	func setupInputBarView() {
		view.addSubview(inputBarView)

		inputBarView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			inputBarView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
			inputBarView.leftAnchor.constraint(equalTo: view.leftAnchor),
			inputBarView.rightAnchor.constraint(equalTo: view.rightAnchor),
			inputBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
		])
	}

	func reloadMessages(with model: ChatModel.FetchMessage.ViewModel) {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			self.messagesGroups = model.messageGroups
			self.tableView.reloadData()
			self.tableView.layoutIfNeeded()

			let lastSection = tableView.numberOfSections - 1
			let lastRow = tableView.numberOfRows(inSection: lastSection) - 1

			guard lastSection >= 0, lastRow >= 0 else { return }

			let indexPath = IndexPath(row: lastRow, section: lastSection)

			self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
		}
	}

	func addOlderMessages(with model: ChatModel.FetchMessage.ViewModel) {

		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			let mergedMessagesGroups = messagesGroups.merge(model.messageGroups).sorted()

			var sectionsSet = IndexSet()
			var rowsIndexPaths = [IndexPath]()
			let oldMessagesGroups = messagesGroups

			messagesGroups = mergedMessagesGroups

			mergedMessagesGroups.enumerated().forEach { (sectionIndex, messagesGroup) in

				let oldMessagesGroup = oldMessagesGroups.first { $0 == messagesGroup }

				if let oldMessagesGroup {
					let newMessagesNumber = messagesGroup.messages.count
					let oldMessagesNumber = oldMessagesGroup.messages.count

					let newRowsNumber = newMessagesNumber - oldMessagesNumber

					rowsIndexPaths += (0..<newRowsNumber)
						.map { IndexPath(row: $0, section: sectionIndex)}

				} else {
					sectionsSet.insert(sectionIndex)
				}
			}

			let beforeOffsetY = self.tableView.contentOffset.y
			let tempOffsetY = beforeOffsetY <= .zero ? abs(beforeOffsetY) + 1 : .zero

			UIView.animate(withDuration: .zero) {
				self.tableView.performBatchUpdates {
					self.tableView.contentOffset.y += tempOffsetY
					self.tableView.insertRows(at: rowsIndexPaths, with: .automatic)
					self.tableView.insertSections(sectionsSet, with: .automatic)
				} completion: { finished in
					guard beforeOffsetY <= 0 else { return }

					self.tableView.contentOffset.y -= tempOffsetY
				}
			}
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

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		messagesGroups[section].messages.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let section = indexPath.section
		let row = indexPath.row
		let messageGroup = messagesGroups[section]
		let message = messageGroup.messages[row]

		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

		cell.textLabel?.numberOfLines = 0
		cell.textLabel?.text = message.text

		return cell
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		guard !isRefreshing, scrollView.isTracking else { return }

		let visibleSize = scrollView.visibleSize
		let contentOffset = scrollView.contentOffset

		let request = ChatModel.TableMessagesInfo.Request(visibleSize: visibleSize, contentOffset: contentOffset)

		interactor?.messagesDidScroll(request: request)

	}

	func numberOfSections(in tableView: UITableView) -> Int {
		messagesGroups.count
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		let date = messagesGroups[section].date

		return ChatDateSection(date: date)
	}
}

// MARK: - InputBarDelegate

extension ChatViewController: InputBarViewDelegate {

	func inputBar(_ inputBar: InputBarView, didPressSendButtonWith text: String) {

	}

	func inputBar(_ inputBar: InputBarView, didChangeIntrinsicContentFrom size: CGSize) {

		let offsetY = inputBar.frame.height - size.height
		let contentHeight = tableView.contentSize.height
		let visibleContentHeight = tableView.visibleSize.height
		let contentOffsetY = tableView.contentOffset.y

		let didScrollToBottom = (contentHeight - visibleContentHeight) == contentOffsetY

		guard !didScrollToBottom else { return }

		tableView.contentOffset.y += offsetY
	}

	func inputBar(_ inputBar: InputBarView, textViewTextDidChangeTo text: String) {}
}
