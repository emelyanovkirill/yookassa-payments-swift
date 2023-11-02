import UIKit
import YooMoneyUI

final class SbpConfirmationViewController: UIViewController {

    // MARK: - VIPER

    var output: SbpConfirmationViewOutput!

    // MARK: - Data

    private var viewModels: [SbpBankCellViewModel] = []

    // MARK: - UI properties

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.setStyles(
            UITableView.Styles.primary,
            UIView.Styles.YKSdk.defaultBackground
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.register(TitleItemTableViewCell.self)
        return view
    }()

    private var activityIndicatorView: UIView?

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.setStyles(UIView.Styles.YKSdk.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentView = self.actionTitleTextDialog
        return view
    }()

    lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        let dialogView = ActionTitleTextDialog()
        dialogView.tintColor = CustomizationStorage.shared.mainScheme
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.setStyles(ActionTitleTextDialog.Styles.fail)
        dialogView.text = CommonLocalized.PlaceholderView.text
        dialogView.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        dialogView.delegate = output
        return dialogView
    }()

    // MARK: - Constraints

    private lazy var tableViewHeightConstraint = {
        let constraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .highest
        return constraint
    }()

    // MARK: - Initializing

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
        setupNavigationBar()
    }

    // MARK: - Setup

    private func setup() {
        navigationItem.setStyles(UINavigationItem.Styles.onlySmallTitle)
    }

    private func setupView() {
        view.preservesSuperviewLayoutMargins = true
        view.backgroundColor = .clear
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        let constraints = [
            tableViewHeightConstraint,
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.prefersLargeTitles = false

        let leftItem = UILabel()
        leftItem.setStyles(UILabel.DynamicStyle.headline1)
        leftItem.text = Localized.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftItem)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fixTableViewHeight()
    }

    private func fixTableViewHeight() {
        let contentEffectiveHeight = tableView.contentSize.height
            + tableView.contentInset.top
            + tableView.contentInset.bottom
            + UIScreen.safeAreaInsets.bottom
            + Constants.navigationBarHeight

        let newValue = viewModels.isEmpty
            ? Constants.defaultTableViewHeight
            : contentEffectiveHeight

        if tableViewHeightConstraint.constant != newValue {
            tableViewHeightConstraint.constant = newValue
        }
    }

    // MARK: - Action
}

// MARK: - SbpConfirmationViewInput

extension SbpConfirmationViewController: SbpConfirmationViewInput {
    func showPlaceholder(message: String) {
        actionTitleTextDialog.title = message
        showPlaceholder()
    }

    func showMissedBankPlaceholder() {
        actionTitleTextDialog.title = Localized.CantOpenBankPlaceholder.title
        actionTitleTextDialog.text = Localized.CantOpenBankPlaceholder.text
        actionTitleTextDialog.buttonTitle = Localized.CantOpenBankPlaceholder.buttonTitle
        showPlaceholder()
    }

    func setViewModels(_ banks: [SbpBankCellViewModel]) {
        viewModels = banks
        tableView.reloadData()
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension SbpConfirmationViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }
}

// MARK: - UITableViewDataSource

extension SbpConfirmationViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModels.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let viewModel = viewModels[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withType: TitleItemTableViewCell.self,
            for: indexPath
        )
        cell.title = viewModel.title
        cell.accessoryType = viewModel.accessoryType
        cell.appendStyle(UIView.Styles.YKSdk.defaultBackground)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SbpConfirmationViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.didSelectBankItemAction(viewModels[indexPath.row].actionType)
    }
}

// MARK: - Localization

private extension SbpConfirmationViewController {
    enum Localized {
        // swiftlint:disable:next superfluous_disable_command
        // swiftlint:disable line_length
        static let title = NSLocalizedString(
            "SbpConfirmationView.Title",
            bundle: Bundle.framework,
            value: "Выберите банк для оплаты",
            comment: "Title в NavigationBar на экране СБП подтверждения"
        )
        enum CantOpenBankPlaceholder {
            static let title = NSLocalizedString(
                "SbpConfirmationView.CantOpenBankPlaceholder.Title",
                value: "Не сработало",
                comment: "Title плейсхолдера на экране СБП подтверждения https://disk.yandex.ru/i/uJO-ou0VT_t1_g"
            )
            static let text = NSLocalizedString(
                "SbpConfirmationView.CantOpenBankPlaceholder.Text",
                value: "Кажется, у вас не установлено приложение этого банка. Установите или выберите другой банк",
                comment: "Text плейсхолдера на экране СБП подтверждения https://disk.yandex.ru/i/uJO-ou0VT_t1_g"
            )
            static let buttonTitle = NSLocalizedString(
                "SbpConfirmationView.CantOpenBankPlaceholder.ButtonTitle",
                value: "Понятно",
                comment: "Title кнопки плейсхолдера на экране СБП подтверждения https://disk.yandex.ru/i/uJO-ou0VT_t1_g"
            )
        }
        // swiftlint:enable line_length
    }
}

// MARK: - Constants

private extension SbpConfirmationViewController {
    enum Constants {
        static let defaultTableViewHeight: CGFloat = 360
        static let navigationBarHeight: CGFloat = 44
    }
}
