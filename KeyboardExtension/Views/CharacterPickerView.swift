import UIKit
import KeyboardCore

@MainActor final class CharacterPickerView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onSelect: ((String) -> Void)?
    var onMode: ((Int) -> Void)?
    var onDelete: (() -> Void)?
    private var palette: CharacterPalette
    private var categoryID: String
    private var emojiRecents: RecentCharacters
    private var symbolRecents: RecentCharacters
    private var tokens: ThemeTokens
    private var characters: [String] = []
    private var layoutWidth: CGFloat = 0
    private var strongAppearance: Bool { UIAccessibility.isReduceTransparencyEnabled || traitCollection.accessibilityContrast == .high }
    private let tabs = UISegmentedControl(items: CharacterPalette.allCases.map(\.title))
    private let categories = UIStackView()
    private let categoryScroll = UIScrollView()
    private let collection: UICollectionView
    private let emptyLabel = UILabel()
    private let footer = UIStackView()

    init(palette: CharacterPalette, tokens: ThemeTokens, emojiRecents: RecentCharacters, symbolRecents: RecentCharacters) {
        self.palette = palette; self.tokens = tokens
        self.emojiRecents = emojiRecents; self.symbolRecents = symbolRecents
        categoryID = CharacterCatalog.categories(for: palette)[0].id
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2; layout.minimumLineSpacing = 2
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        accessibilityIdentifier = "character-picker"
        let stack = UIStackView(); stack.axis = .vertical; stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false; addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        tabs.selectedSegmentIndex = palette == .emoji ? 0 : 1
        tabs.accessibilityLabel = "絵文字と記号の切り替え"
        tabs.heightAnchor.constraint(equalToConstant: 32).isActive = true
        tabs.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.palette = self.tabs.selectedSegmentIndex == 0 ? .emoji : .symbol
            self.categoryID = CharacterCatalog.categories(for: self.palette)[0].id
            self.reloadCategories(); self.reloadCharacters()
        }, for: .valueChanged)
        stack.addArrangedSubview(tabs)
        categories.axis = .horizontal; categories.spacing = 4
        categories.translatesAutoresizingMaskIntoConstraints = false
        categoryScroll.showsHorizontalScrollIndicator = false; categoryScroll.addSubview(categories)
        NSLayoutConstraint.activate([
            categories.leadingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.leadingAnchor),
            categories.trailingAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.trailingAnchor),
            categories.topAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.topAnchor),
            categories.bottomAnchor.constraint(equalTo: categoryScroll.contentLayoutGuide.bottomAnchor),
            categories.heightAnchor.constraint(equalTo: categoryScroll.frameLayoutGuide.heightAnchor),
            categoryScroll.heightAnchor.constraint(equalToConstant: 36)
        ])
        stack.addArrangedSubview(categoryScroll)
        collection.backgroundColor = .clear; collection.alwaysBounceVertical = true
        collection.dataSource = self; collection.delegate = self
        collection.accessibilityIdentifier = "character-picker-grid"
        collection.register(CharacterCell.self, forCellWithReuseIdentifier: "character")
        stack.addArrangedSubview(collection)
        emptyLabel.text = "選んだ項目がここに表示されます"; emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 13); emptyLabel.numberOfLines = 2
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false; collection.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: collection.frameLayoutGuide.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: collection.frameLayoutGuide.centerYAnchor),
            emptyLabel.widthAnchor.constraint(lessThanOrEqualTo: collection.frameLayoutGuide.widthAnchor, constant: -16)
        ])
        footer.axis = .horizontal; footer.spacing = 3; footer.distribution = .fillEqually
        for (title, mode) in [("かな", 0), ("ABC", 1), ("記号キー", 3)] {
            footer.addArrangedSubview(actionButton(title) { [weak self] in self?.onMode?(mode) })
        }
        footer.addArrangedSubview(actionButton("空白") { [weak self] in self?.onSelect?(" ") })
        let delete = actionButton("⌫") { [weak self] in self?.onDelete?() }
        delete.accessibilityLabel = "1文字削除"; footer.addArrangedSubview(delete)
        footer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stack.addArrangedSubview(footer)
        reloadCategories(); reloadCharacters(); applyTheme(tokens)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func applyTheme(_ tokens: ThemeTokens) {
        self.tokens = tokens
        tabs.selectedSegmentTintColor = UIColor(themeHex: tokens.key)
        tabs.setTitleTextAttributes([.foregroundColor: UIColor(themeHex: tokens.canvasText)], for: .normal)
        tabs.setTitleTextAttributes([.foregroundColor: UIColor(themeHex: tokens.text)], for: .selected)
        emptyLabel.textColor = UIColor(themeHex: tokens.canvasText)
        footer.arrangedSubviews.forEach { KeyboardKeyStyle.apply($0, tokens: tokens, strong: strongAppearance) }
        styleCategories(); collection.reloadData()
    }
    private func actionButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let button = KeyboardActionButton(type: .system)
        button.setTitle(title, for: .normal); button.accessibilityLabel = title
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
    private func reloadCategories() {
        categories.arrangedSubviews.forEach { categories.removeArrangedSubview($0); $0.removeFromSuperview() }
        let entries = [("recent", "◷ 最近")] + CharacterCatalog.categories(for: palette).map { ($0.id, $0.title) }
        for (id, title) in entries {
            let button = actionButton(title) { [weak self] in
                guard let self else { return }; self.categoryID = id
                self.styleCategories(); self.reloadCharacters()
            }
            button.accessibilityIdentifier = "character-category-\(id)"
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
            categories.addArrangedSubview(button)
        }
        categoryScroll.setContentOffset(.zero, animated: false); styleCategories()
    }
    private func styleCategories() {
        for case let button as UIButton in categories.arrangedSubviews {
            KeyboardKeyStyle.apply(button, tokens: tokens, strong: strongAppearance)
            let selected = button.accessibilityIdentifier == "character-category-\(categoryID)"
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
            button.layer.borderWidth = selected ? 1.5 : 0
            button.layer.borderColor = UIColor(themeHex: tokens.canvasAccent).cgColor
        }
    }
    private func reloadCharacters() {
        characters = categoryID == "recent" ? (palette == .emoji ? emojiRecents.items : symbolRecents.items) :
            CharacterCatalog.categories(for: palette).first { $0.id == categoryID }?.characters ?? []
        emptyLabel.isHidden = !characters.isEmpty
        collection.reloadData(); collection.setContentOffset(.zero, animated: false)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { characters.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "character", for: indexPath) as! CharacterCell
        let text = characters[indexPath.item]
        cell.label.text = text
        cell.label.font = .systemFont(ofSize: palette == .emoji ? 28 : text.count > 3 ? 12 : 22)
        cell.label.textColor = UIColor(themeHex: tokens.canvasText)
        cell.accessibilityLabel = text; cell.accessibilityHint = "タップして入力"
        cell.accessibilityTraits = .button
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = characters[indexPath.item]
        if palette == .emoji { emojiRecents.record(text) } else { symbolRecents.record(text) }
        onSelect?(text)
        collectionView.deselectItem(at: indexPath, animated: false)
        if categoryID == "recent" { reloadCharacters() }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns = max(1, min(8, Int((collectionView.bounds.width + 2) / 46)))
        return CGSize(width: max(44, floor((collectionView.bounds.width - CGFloat(columns - 1) * 2) / CGFloat(columns))), height: 44)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if layoutWidth != collection.bounds.width {
            layoutWidth = collection.bounds.width
            collection.collectionViewLayout.invalidateLayout()
        }
    }
}

@MainActor private final class CharacterCell: UICollectionViewCell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame); isAccessibilityElement = true
        label.textAlignment = .center; label.adjustsFontSizeToFitWidth = true; label.minimumScaleFactor = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false; contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            label.topAnchor.constraint(equalTo: contentView.topAnchor), label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isHighlighted: Bool { didSet { contentView.alpha = isHighlighted ? 0.45 : 1 } }
}
