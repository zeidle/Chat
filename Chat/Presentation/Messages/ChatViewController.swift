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

	// MARK: - Internal properties

	var interactor: ChatBusinessLogic?
	var router: (ChatRoutingLogic & ChatDataPassing)?

	// MARK: - private properties
	private var isRefreshing: Bool = false
	private var messagesContentSize: CGSize = .zero
	private let cellId = "cellId"
	private var titles: [String] = []
	private lazy var tableView: UITableView = {
		let tableView = UITableView()

		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
		tableView.allowsSelection = false
		tableView.keyboardDismissMode = .interactive

		tableView.refreshControl = refreshControl
		tableView.refreshControl?.layer.zPosition = -1

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
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
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

			self.titles = model.cellTitles
			self.tableView.reloadData()
			self.tableView.setContentOffset(.init(x: 0, y: .max), animated: false)
		}
	}

	func addOlderMessages(with model: ChatModel.FetchMessage.ViewModel) {

		DispatchQueue.main.async { [weak self] in
			guard let self else { return }

			let oldContentHeight = tableView.contentSize.height
			self.titles.insert(contentsOf: model.cellTitles, at: 0)

			self.tableView.reloadData()
			self.tableView.layoutIfNeeded()

			let newContentHeight = self.tableView.contentSize.height

			let offsetY = newContentHeight - oldContentHeight

			var contentOffset = self.tableView.contentOffset
			contentOffset.y += offsetY

			self.tableView.setContentOffset(contentOffset, animated: false)
		}
	}

	func showRefreshControl() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			self.refreshControl.beginRefreshing()
			self.isRefreshing = true
		}
	}

	func hideRefreshControl() {
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			self.refreshControl.endRefreshing()
			self.isRefreshing = false
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
		titles.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let title = titles[indexPath.row]

		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

		cell.textLabel?.text = title

		return cell
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {

		guard scrollView.isTracking else { return }

		let visibleSize = scrollView.visibleSize
		let contentOffset = scrollView.contentOffset

		let request = ChatModel.TableMessagesInfo.Request(visibleSize: visibleSize, contentOffset: contentOffset)

		interactor?.messagesDidScroll(request: request)
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
