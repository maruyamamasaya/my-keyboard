import UIKit
import OSLog
import KeyboardCore

@MainActor final class KeyboardViewController: UIInputViewController {
    private let lifecycleLog = Logger(subsystem: "maruyama.MyKeyboard", category: "KeyboardLifecycle")
    private var composition = Composition()
    private let liveSession = LiveTextSession()
    private var wordReconversion: WordReconversion?
    private var wordCandidates: [ConversionChoice] = []
    private var showsCandidates = true
    private var candidateVisibilityButton: UIButton?
    private var preferences = KeyboardPreferences()
    private var appearance = ThemeSelection()
    private let cosmos = CosmosBackgroundView(frame: .zero)
    private var dictionary: [DictionaryEntry] = []
    private var conversion: AzooKeyConversion?
    private var pendingConversion: DispatchWorkItem?
    private var deletionTimer: Timer?
    private var recent: RecentCommit?
    private var replacing: RecentCommit?
    private var mode = 0
    private var uppercase = false
    private var ownEdit = false
    private var landscape = false
    private var heightConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    private let bodyStack = UIStackView()
    private let grid = UIStackView()
    private let headerStack = UIStackView()
    private var returnButton: UIButton?
    private let statusLabel = UILabel()
    private let candidateRow = UIStackView()
    private let globe = UIButton(type: .system)
    private let clipboardPanel = UIStackView()
    private var clipboard: ClipboardStore?
    private var clipboardDraft: String?
    private var clipboardSearch = ""
    private var spacePosition: CGFloat = 0
    private var spaceDidDrag = false
    private var alignmentConstraint: NSLayoutConstraint?
    private var experimentalEditingEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "EnableExperimentalHostReplacement") as? Bool == true
    }
    private var strongAppearance: Bool { UIAccessibility.isReduceTransparencyEnabled || traitCollection.accessibilityContrast == .high || cosmos.image != nil }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if isViewLoaded { applyAppearance() }
    }
    @objc private func applyAppearance() {
        view.backgroundColor = UIColor(themeHex: appearance.tokens.background)
        clipboardPanel.backgroundColor = UIColor(themeHex: appearance.tokens.background)
        cosmos.tokens = appearance.tokens
        statusLabel.textColor = UIColor(themeHex: appearance.tokens.canvasText)
        func visit(_ parent: UIView) {
            for child in parent.subviews {
                if let key = child as? FlickButton { key.applyTheme(appearance.tokens, strong: strongAppearance) }
                else if let button = child as? UIButton { KeyboardKeyStyle.apply(button, tokens: appearance.tokens, strong: strongAppearance) }
                visit(child)
            }
        }
        visit(bodyStack); visit(clipboardPanel)
        globe.backgroundColor = .clear; globe.layer.borderWidth = 0; globe.layer.shadowOpacity = 0
        globe.tintColor = UIColor(themeHex: appearance.tokens.canvasAccent)
        updateReturnKey()
        cosmos.setNeedsDisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        primaryLanguage = "ja-JP"
        view.backgroundColor = .systemBackground
        cosmos.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cosmos)
        let boundary = UIView(); boundary.backgroundColor = UIColor(themeHex: appearance.tokens.accent).withAlphaComponent(0.25)
        boundary.translatesAutoresizingMaskIntoConstraints = false; view.addSubview(boundary)
        NSLayoutConstraint.activate([boundary.topAnchor.constraint(equalTo: view.topAnchor), boundary.leadingAnchor.constraint(equalTo: view.leadingAnchor), boundary.trailingAnchor.constraint(equalTo: view.trailingAnchor), boundary.heightAnchor.constraint(equalToConstant: 0.5)])
        NotificationCenter.default.addObserver(self, selector: #selector(applyAppearance), name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyAppearance), name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification, object: nil)
        NSLayoutConstraint.activate([cosmos.leadingAnchor.constraint(equalTo: view.leadingAnchor), cosmos.trailingAnchor.constraint(equalTo: view.trailingAnchor), cosmos.topAnchor.constraint(equalTo: view.topAnchor), cosmos.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        bodyStack.axis = .vertical; bodyStack.spacing = 4
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyStack)
        NSLayoutConstraint.activate([
            bodyStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            bodyStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            bodyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 4),
            bodyStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -4)
        ])
        widthConstraint = bodyStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -8)
        widthConstraint?.isActive = true
        // Keep the same header geometry before, during and after prediction.
        let header = UIView(); headerStack.axis = .vertical; headerStack.spacing = 4
        headerStack.translatesAutoresizingMaskIntoConstraints = false; header.addSubview(headerStack)
        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(equalToConstant: 96),
            headerStack.topAnchor.constraint(equalTo: header.topAnchor, constant: 2),
            headerStack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -2),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 12),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -12)
        ])
        bodyStack.addArrangedSubview(header)
        statusLabel.font = .systemFont(ofSize: 14, weight: .light)
        statusLabel.adjustsFontForContentSizeCategory = false
        statusLabel.adjustsFontSizeToFitWidth = true; statusLabel.minimumScaleFactor = 0.8
        statusLabel.accessibilityLabel = "入力状態"
        statusLabel.isHidden = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 2),
            statusLabel.leadingAnchor.constraint(equalTo: headerStack.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: headerStack.trailingAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
        let candidateScroll = UIScrollView(); candidateScroll.showsHorizontalScrollIndicator = false
        candidateRow.axis = .horizontal; candidateRow.spacing = 6; candidateRow.translatesAutoresizingMaskIntoConstraints = false
        candidateScroll.addSubview(candidateRow)
        NSLayoutConstraint.activate([
            candidateRow.leadingAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.leadingAnchor),
            candidateRow.trailingAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.trailingAnchor),
            candidateRow.topAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.topAnchor),
            candidateRow.bottomAnchor.constraint(equalTo: candidateScroll.contentLayoutGuide.bottomAnchor),
            candidateRow.heightAnchor.constraint(equalTo: candidateScroll.frameLayoutGuide.heightAnchor),
            candidateScroll.heightAnchor.constraint(equalToConstant: 44)
        ])
        headerStack.addArrangedSubview(candidateScroll)
        grid.axis = .horizontal; grid.distribution = .fill; grid.spacing = 5
        bodyStack.addArrangedSubview(grid)
        let toolbarScroll = UIScrollView(); toolbarScroll.showsHorizontalScrollIndicator = false
        let toolbar = UIStackView(); toolbar.axis = .horizontal; toolbar.spacing = 4
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarScroll.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: toolbarScroll.contentLayoutGuide.leadingAnchor), toolbar.trailingAnchor.constraint(equalTo: toolbarScroll.contentLayoutGuide.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: toolbarScroll.contentLayoutGuide.topAnchor), toolbar.bottomAnchor.constraint(equalTo: toolbarScroll.contentLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalTo: toolbarScroll.frameLayoutGuide.heightAnchor), toolbarScroll.heightAnchor.constraint(equalToConstant: 44)
        ])
        let visibility = button("候補表示", role: .toolbar) { [weak self] in
            guard let self else { return }; self.showsCandidates.toggle(); self.render()
        }
        candidateVisibilityButton = visibility; toolbar.addArrangedSubview(visibility)
        toolbar.addArrangedSubview(button("✦ 履歴", role: .toolbar) { [weak self] in self?.showClipboard() })
        toolbar.addArrangedSubview(button("←", role: .toolbar) { [weak self] in self?.moveCursor(-1) })
        toolbar.addArrangedSubview(button("→", role: .toolbar) { [weak self] in self?.moveCursor(1) })
        toolbar.addArrangedSubview(button("確定", role: .toolbar) { [weak self] in self?.commitReading() })
        toolbar.addArrangedSubview(button("取消", role: .toolbar) { [weak self] in self?.cancelComposition() })
        toolbar.insertArrangedSubview(button("再変換", role: .toolbar) { [weak self] in self?.startReconversion() }, at: 1)
        toolbar.addArrangedSubview(button("単語削除", role: .toolbar) { [weak self] in self?.deleteWord() })
        let toolbarRow = UIStackView(); toolbarRow.axis = .horizontal; toolbarRow.spacing = 4
        toolbarRow.addArrangedSubview(toolbarScroll)
        let dismiss = button("キーボードを閉じる", role: .toolbar) { [weak self] in
            guard let self else { return }
            self.lifecycleLog.info("User requested keyboard dismissal")
            self.commitReading(); self.stopActivity(); self.closeClipboard(); self.dismissKeyboard()
        }
        dismiss.setTitle(nil, for: .normal); dismiss.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        dismiss.accessibilityHint = "入力中の変換を確定してキーボードを閉じます"
        dismiss.widthAnchor.constraint(equalToConstant: 44).isActive = true
        toolbarRow.addArrangedSubview(dismiss)
        headerStack.addArrangedSubview(toolbarRow)
        globe.setImage(UIImage(systemName: "globe"), for: .normal); globe.accessibilityLabel = "次のキーボード"
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        let globeWidth = globe.widthAnchor.constraint(equalToConstant: 48)
        globeWidth.priority = .defaultHigh; globeWidth.isActive = true
        toolbar.insertArrangedSubview(globe, at: 0)
        clipboardPanel.axis = .vertical; clipboardPanel.spacing = 4; clipboardPanel.isHidden = true
        clipboardPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clipboardPanel)
        NSLayoutConstraint.activate([
            clipboardPanel.leadingAnchor.constraint(equalTo: grid.leadingAnchor), clipboardPanel.trailingAnchor.constraint(equalTo: grid.trailingAnchor),
            clipboardPanel.topAnchor.constraint(equalTo: grid.topAnchor), clipboardPanel.bottomAnchor.constraint(equalTo: grid.bottomAnchor)
        ])
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 360)
        heightConstraint?.priority = .defaultHigh; heightConstraint?.isActive = true
        buildGrid()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifecycleLog.info("Keyboard appearing")
        preferences = (try? PreferencesStore())?.load() ?? .init()
        showsCandidates = preferences.showsCandidates
        let themeStore = try? ThemeStore()
        appearance = themeStore?.load(legacy: preferences.theme) ?? .init()
        cosmos.image = nil
        applyAppearance()
        dictionary = (try? UserDictionaryStore().load()) ?? []
        conversion = conversion ?? AzooKeyConversion()
        applyLayout(); updateCandidates()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let isLandscape = (view.window?.windowScene?.interfaceOrientation.isLandscape ?? false)
        if isLandscape != landscape { landscape = isLandscape; applyLayout() }
        globe.isHidden = !needsInputModeSwitchKey
        updateReturnKey()
    }
    override func viewWillDisappear(_ animated: Bool) {
        lifecycleLog.info("Keyboard disappearing")
        commitReading(); stopActivity(); cancelComposition(); conversion?.close(); closeClipboard()
        recent = nil
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        lifecycleLog.warning("Keyboard received memory warning")
        super.didReceiveMemoryWarning(); stopActivity(); conversion?.close(); conversion = nil
        closeClipboard(); dictionary = []; cancelComposition(); recent = nil
        cosmos.image = nil
    }
    override func textWillChange(_ textInput: (any UITextInput)?) { if !ownEdit { recent = nil } }
    override func textDidChange(_ textInput: (any UITextInput)?) {
        if !ownEdit {
            let snapshot = DocumentProxyAdapter(proxy: textDocumentProxy).snapshot
            if snapshot.documentID == nil { lifecycleLog.debug("Host document identity unavailable") }
            if liveSession.isActive && liveSession.matches(snapshot) { return }
            // Host edits or focus changes relinquish ownership; never erase their text.
            liveSession.abandon(); cancelComposition(); recent = nil
        }
        updateReturnKey()
    }

    private func applyLayout() {
        let profile = preferences.profile(landscape: landscape)
        heightConstraint?.constant = 360
        grid.spacing = profile.spacing
        overrideUserInterfaceStyle = appearance.tokens.dark ? .dark : .light
        // Alignment and width are expressed by frame constraints; no orientation-specific fixed screen size.
        widthConstraint?.isActive = false
        alignmentConstraint?.isActive = false
        // center constraint from setup is replaced by the chosen alignment.
        view.constraints.filter { $0.firstItem as? UIStackView === bodyStack && $0.firstAttribute == .centerX }.forEach { $0.isActive = false }
        widthConstraint = bodyStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: profile.widthFraction, constant: -8)
        widthConstraint?.isActive = true
        let alignment: NSLayoutConstraint
        switch profile.alignment {
        case .left: alignment = bodyStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4)
        case .center: alignment = bodyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        case .right: alignment = bodyStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4)
        }
        alignmentConstraint = alignment; alignment.isActive = true
        buildGrid()
    }
    private func button(_ title: String, role: KeyboardKeyRole = .utility, _ action: @escaping () -> Void) -> UIButton {
        let button = KeyboardActionButton(frame: .zero); button.keyRole = role
        button.setTitle(title, for: .normal); button.accessibilityLabel = title
        button.titleLabel?.numberOfLines = role == .candidate ? 1 : 2; button.titleLabel?.textAlignment = .center
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleLabel?.adjustsFontSizeToFitWidth = true; button.titleLabel?.minimumScaleFactor = 0.75
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
        if role == .candidate {
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.titleLabel?.adjustsFontSizeToFitWidth = false
        }
        let minimumHeight = button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        minimumHeight.priority = .defaultHigh; minimumHeight.isActive = true
        let symbols = ["候補表示": "eye.slash", "✦ 履歴": "doc.on.clipboard", "←": "chevron.left", "→": "chevron.right", "確定": "checkmark.circle", "取消": "arrow.uturn.backward", "再変換": "arrow.triangle.2.circlepath", "単語削除": "delete.left.fill", "⌫": "delete.left", "☺": "face.smiling"]
        if let symbol = symbols[title] {
            button.setTitle(nil, for: .normal); button.setImage(UIImage(systemName: symbol), for: .normal)
        }
        KeyboardKeyStyle.apply(button, tokens: appearance.tokens, strong: strongAppearance)
        button.addAction(UIAction { [weak self, weak button] _ in
            guard let self, let button else { return }
            KeyboardKeyStyle.apply(button, tokens: self.appearance.tokens, pressed: true, strong: self.strongAppearance)
        }, for: .touchDown)
        button.addAction(UIAction { [weak self, weak button] _ in
            guard let self, let button else { return }
            KeyboardKeyStyle.apply(button, tokens: self.appearance.tokens, strong: self.strongAppearance)
            self.updateReturnKey()
        }, for: [.touchUpInside, .touchUpOutside, .touchCancel])
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
    private func clear(_ stack: UIStackView) { stack.arrangedSubviews.forEach { stack.removeArrangedSubview($0); $0.removeFromSuperview() } }
    private func buildGrid() {
        clear(grid)
        var keys = FlickMap.japanese
        if mode == 1 {
            keys = ["abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz", "@_-", "⇧", ".,/", "!?'"]
                .map { value in FlickKey(value == "⇧" ? [value] : value.map { uppercase ? String($0).uppercased() : String($0) }) }
        } else if mode == 2 {
            keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "-"].map { FlickKey([$0]) }
        } else if mode == 3 {
            keys = ["!", "?", "#", "(", ")", "[", "]", "@", "+", "=", "_", "/"].map { FlickKey([$0]) }
        }
        let spacing = preferences.profile(landscape: landscape).spacing
        func column() -> UIStackView {
            let stack = UIStackView(); stack.axis = .vertical; stack.spacing = spacing
            stack.distribution = .fillEqually
            return stack
        }
        let left = column(), center = column(), right = column()
        grid.addArrangedSubview(left); grid.addArrangedSubview(center); grid.addArrangedSubview(right)
        NSLayoutConstraint.activate([
            left.widthAnchor.constraint(equalTo: right.widthAnchor),
            center.widthAnchor.constraint(equalTo: left.widthAnchor, multiplier: 3, constant: spacing * 2)
        ])
        left.addArrangedSubview(button("記号") { [weak self] in self?.switchMode(3) })
        left.addArrangedSubview(button("123") { [weak self] in self?.switchMode(2) })
        left.addArrangedSubview(button("あA") { [weak self] in
            guard let self else { return }; self.switchMode(self.mode == 0 ? 1 : 0)
        })
        left.addArrangedSubview(button("☺") { [weak self] in self?.switchMode(4) })
        if mode == 4 {
            keys = ["😀", "😊", "🥰", "😂", "😎", "🥲", "👍", "🙏", "❤️", "✨", "🎉", "🌸"].map { FlickKey([$0]) }
        }
        for rowIndex in 0..<4 {
            let row = UIStackView(); row.axis = .horizontal; row.distribution = .fillEqually; row.spacing = spacing
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            for key in keys[(rowIndex * 3)..<(rowIndex * 3 + 3)] {
                let control = FlickButton(key: key)
                control.applyTheme(appearance.tokens, strong: strongAppearance)
                control.onCommit = { [weak self] in self?.input($0) }
                row.addArrangedSubview(control)
            }
            center.addArrangedSubview(row)
        }
        right.distribution = .fill
        let delete = button("⌫") { [weak self] in self?.deleteOne() }
        delete.accessibilityLabel = "1文字削除。長押しで連続削除"
        delete.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(repeatDelete(_:))))
        let space = button("空白") { [weak self] in
            guard let self, !self.spaceDidDrag else { self?.spaceDidDrag = false; return }
            self.commitReading(); self.edit { self.textDocumentProxy.insertText(" ") }; self.recent = nil
        }
        space.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragSpace(_:))))
        let enter = button("改行", role: .primary) { [weak self] in
            guard let self else { return }
            if !self.composition.reading.isEmpty { self.commitReading(); return }
            self.edit { self.textDocumentProxy.insertText("\n") }; self.recent = nil
        }
        enter.titleLabel?.numberOfLines = 2; enter.titleLabel?.textAlignment = .center
        returnButton = enter
        right.addArrangedSubview(delete); right.addArrangedSubview(space); right.addArrangedSubview(enter)
        NSLayoutConstraint.activate([
            delete.heightAnchor.constraint(equalTo: space.heightAnchor),
            enter.heightAnchor.constraint(equalTo: delete.heightAnchor, multiplier: 2, constant: spacing)
        ])
        updateReturnKey(); applyAppearance()
    }
    private func switchMode(_ value: Int) {
        commitReading(); mode = value; buildGrid()
    }
    private func updateReturnKey() {
        let title: String
        if !composition.reading.isEmpty { title = "確定" }
        else {
            switch textDocumentProxy.returnKeyType ?? .default {
            case .go: title = "開く"
            case .search, .google, .yahoo: title = "検索"
            case .send: title = "送信"
            case .done: title = "完了"
            case .next: title = "次へ"
            case .join: title = "参加"
            case .route: title = "経路"
            default: title = "改行"
            }
        }
        returnButton?.setTitle(title + "\n↵", for: .normal); returnButton?.accessibilityLabel = title
        if let returnButton {
            KeyboardKeyStyle.apply(returnButton, tokens: appearance.tokens, strong: strongAppearance)
        }
    }
    private func input(_ text: String) {
        stopWordEditing()
        recent = nil
        if text == "⇧" { uppercase.toggle(); buildGrid(); return }
        if text == "゛小" { composition.modifyPreviousKana(); updateCandidates(); return }
        if mode == 0 {
            if !composition.insert(text) { showStatus("未確定の読みが上限です。確定してください。"); return }
            updateCandidates()
        } else { edit { textDocumentProxy.insertText(text) } }
    }
    private func updateCandidates() {
        pendingConversion?.cancel(); render()
        guard !composition.reading.isEmpty else { return }
        let reading = composition.reading; let revision = composition.revision
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.composition.revision == revision, self.wordReconversion == nil else { return }
            if self.conversion == nil { self.conversion = AzooKeyConversion() }
            guard let conversion = self.conversion else { return }
            let candidates = conversion.candidates(for: reading, preferences: self.preferences, dictionary: self.dictionary)
            if self.composition.apply(candidates, revision: revision) { self.render() }
        }
        pendingConversion = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04, execute: work)
    }
    private func render() {
        updateLiveText()
        updateReturnKey()
        let visible = showsCandidates || wordReconversion != nil
        candidateRow.isHidden = !visible
        candidateVisibilityButton?.setImage(UIImage(systemName: visible ? "eye" : "eye.slash"), for: .normal)
        candidateVisibilityButton?.isEnabled = wordReconversion == nil
        candidateVisibilityButton?.accessibilityLabel = wordReconversion != nil ? "再変換中は候補を表示" : visible ? "候補を非表示" : "候補を表示"
        candidateVisibilityButton?.accessibilityValue = visible ? "表示中" : "非表示"
        statusLabel.isHidden = true
        clear(candidateRow)
        let revision = composition.revision
        let selectedWord = wordReconversion?.selectedIndex
        for choice in wordReconversion == nil ? composition.candidates : wordCandidates {
            candidateRow.addArrangedSubview(button(choice.text, role: .candidate) { [weak self] in
                guard let self, self.composition.revision == revision else { return }
                if let selectedWord {
                    guard self.wordReconversion?.selectedIndex == selectedWord else { return }
                    self.wordReconversion?.choose(choice.text); self.render()
                } else if self.wordReconversion == nil { self.commit(choice) }
            })
        }
    }
    private func showStatus(_ message: String) {
        statusLabel.text = message; statusLabel.isHidden = false; candidateRow.isHidden = true
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    private func updateLiveText() {
        guard replacing == nil else { return }
        // Conversion is meaningful at the end; editing within the reading shows kana.
        let atEnd = composition.cursor == composition.reading.count
        let text = wordReconversion?.text ?? (atEnd ? composition.liveChoice.text : composition.reading)
        let cursor = atEnd || wordReconversion != nil ? text.utf16.count : String(composition.reading.prefix(composition.cursor)).utf16.count
        var success = true
        edit { success = liveSession.update(text, cursorUTF16: cursor, using: DocumentProxyAdapter(proxy: textDocumentProxy)) }
        if !success {
            pendingConversion?.cancel(); composition.reset(); wordReconversion = nil; wordCandidates = []; replacing = nil; conversion?.reset(); recent = nil
        }
    }
    private func edit(_ action: () -> Void) { ownEdit = true; action(); ownEdit = false }
    private func commitReading() {
        guard !composition.reading.isEmpty else { return }
        commit(wordReconversion.map { ConversionChoice($0.text) } ?? composition.liveChoice)
    }
    private func commit(_ choice: ConversionChoice) {
        let reading = composition.reading
        guard !reading.isEmpty else { return }
        var success = true
        edit {
            if let replacing { success = DocumentProxyAdapter(proxy: textDocumentProxy).replace(replacing, with: choice.text) }
            else if liveSession.isActive {
                success = liveSession.finish(choice.text, using: DocumentProxyAdapter(proxy: textDocumentProxy))
            } else { textDocumentProxy.insertText(choice.text) }
        }
        if success {
            conversion?.commit(choice, learning: preferences.learningEnabled)
            recent = RecentCommit(reading: reading, text: choice.text, snapshot: DocumentProxyAdapter(proxy: textDocumentProxy).snapshot)
        }
        cancelComposition()
        if !success { showStatus("入力先が変わったため置換を停止しました。本文を確認してください。"); recent = nil }
    }
    private func cancelComposition() {
        pendingConversion?.cancel()
        edit { liveSession.cancel(using: DocumentProxyAdapter(proxy: textDocumentProxy)) }
        composition.reset(); wordReconversion = nil; wordCandidates = []; replacing = nil; conversion?.reset(); render()
    }
    private func startReconversion() {
        if wordReconversion != nil { wordReconversion?.move(1); refreshWordCandidates(); return }
        if !composition.reading.isEmpty && replacing == nil {
            guard liveSession.isActive, liveSession.matches(DocumentProxyAdapter(proxy: textDocumentProxy).snapshot) else {
                showStatus("入力先が変わりました。現在の入力を確認してください。"); return
            }
            pendingConversion?.cancel()
            conversion = conversion ?? AzooKeyConversion()
            let choices = conversion?.candidates(for: composition.reading, preferences: preferences, dictionary: dictionary, prediction: false) ?? []
            composition.apply(choices, revision: composition.revision)
            wordReconversion = WordReconversion(reading: composition.reading, choice: choices.first ?? .init(composition.reading))
            refreshWordCandidates(); return
        }
        // Committed host replacement retains the existing experimental gate.
        guard experimentalEditingEnabled else { showStatus("再変換は確定前に使ってください。"); return }
        guard let recent, recent.canReplace(in: DocumentProxyAdapter(proxy: textDocumentProxy).snapshot) else {
            showStatus("安全に再変換できる直前の入力がありません。"); return
        }
        replacing = recent; composition.insert(recent.reading); updateCandidates()
    }
    private func stopWordEditing() {
        if wordReconversion != nil {
            composition.apply([], revision: composition.revision); conversion?.reset()
        }
        wordReconversion = nil; wordCandidates = []
    }
    private func refreshWordCandidates() {
        guard let wordReconversion else { return }
        wordCandidates = conversion?.candidates(for: wordReconversion.selected.reading, preferences: preferences, dictionary: dictionary, prediction: false) ?? []
        render()
    }
    private func moveCursor(_ offset: Int) {
        if wordReconversion != nil { wordReconversion?.move(offset); refreshWordCandidates(); return }
        recent = nil
        if composition.reading.isEmpty { edit { textDocumentProxy.adjustTextPosition(byCharacterOffset: offset) } }
        else { composition.moveCursor(offset); updateCandidates() }
    }
    private func deleteOne() {
        stopWordEditing()
        recent = nil
        if composition.reading.isEmpty { edit { textDocumentProxy.deleteBackward() } }
        else { composition.deleteBackward(); updateCandidates() }
    }
    private func deleteWord() {
        guard experimentalEditingEnabled else { showStatus("単語削除は実機検証後に有効化します。"); return }
        recent = nil
        guard composition.reading.isEmpty else { cancelComposition(); return }
        var success = false
        edit { success = DocumentProxyAdapter(proxy: textDocumentProxy).deleteWord() }
        if !success { showStatus("単語境界を確認できません。1文字削除を使ってください。") }
    }
    @objc private func repeatDelete(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            deleteOne(); deletionTimer?.invalidate()
            let timer = Timer(timeInterval: 0.09, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    guard let self, self.deletionTimer != nil, self.view.window != nil else { return }
                    self.deleteOne()
                }
            }
            deletionTimer = timer
            RunLoop.main.add(timer, forMode: .common)
        } else if [.ended, .cancelled, .failed].contains(gesture.state) { deletionTimer?.invalidate(); deletionTimer = nil }
    }
    @objc private func dragSpace(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .began { spacePosition = 0; spaceDidDrag = true }
        let translation = gesture.translation(in: view).x
        let steps = Int((translation - spacePosition) / 14)
        if steps != 0 { moveCursor(max(-5, min(5, steps))); spacePosition = translation }
        if [.ended, .cancelled, .failed].contains(gesture.state) { spaceDidDrag = false }
    }
    private func stopActivity() { pendingConversion?.cancel(); deletionTimer?.invalidate(); deletionTimer = nil }

    private func showClipboard() {
        guard hasFullAccess, preferences.clipboardEnabled else {
            showStatus("履歴は本体の設定とフルアクセスを有効にしてください。"); return
        }
        if !clipboardPanel.isHidden { closeClipboard(); return }
        stopActivity(); clipboardSearch = ""; clipboardDraft = nil; clipboardPanel.isHidden = false; grid.alpha = 0; grid.isUserInteractionEnabled = false
        refreshClipboard()
    }
    private func closeClipboard() { clipboardPanel.isHidden = true; grid.alpha = 1; grid.isUserInteractionEnabled = true; clipboard = nil; clipboardDraft = nil }
    private func refreshClipboard() {
        clear(clipboardPanel)
        guard hasFullAccess, preferences.clipboardEnabled else { closeClipboard(); return }
        let scroll = UIScrollView(); scroll.alwaysBounceVertical = true
        let content = UIStackView(); content.axis = .vertical; content.spacing = 6
        content.translatesAutoresizingMaskIntoConstraints = false; scroll.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
        clipboardPanel.addArrangedSubview(scroll)
        do {
            if clipboard == nil { clipboard = try ClipboardStore(writable: true) }
            try clipboard?.prune()
            let actions = UIStackView(); actions.axis = .horizontal; actions.spacing = 4; actions.distribution = .fillEqually
            actions.addArrangedSubview(button("取り込む") { [weak self] in
                guard let self, self.hasFullAccess else { return }
                // Explicit action only. iOS may request paste permission; no automatic collection.
                let value = UIPasteboard.general.string
                guard let value, ClipboardPolicy.accepts(value) else { self.showStatus("保存できるテキストがありません（1件16KBまで）。"); return }
                self.clipboardDraft = value; self.refreshClipboard()
            })
            actions.addArrangedSubview(button("読みに一致") { [weak self] in
                guard let self else { return }; self.clipboardSearch = self.composition.reading; self.refreshClipboard()
            })
            actions.addArrangedSubview(button("閉じる") { [weak self] in self?.closeClipboard() })
            content.addArrangedSubview(actions)
            if let draft = clipboardDraft {
                let preview = UILabel(); preview.text = draft; preview.textColor = UIColor(themeHex: appearance.tokens.canvasText); preview.numberOfLines = 2; preview.font = .systemFont(ofSize: 14, weight: .light); content.addArrangedSubview(preview)
                content.addArrangedSubview(button("確認した内容を保存") { [weak self] in
                    guard let self, self.hasFullAccess else { return }
                    do { try self.clipboard?.add(draft, limit: self.preferences.safeClipboardLimit); self.clipboardDraft = nil; self.refreshClipboard() }
                    catch { self.showStatus(error.localizedDescription) }
                })
                content.addArrangedSubview(button("保存取消") { [weak self] in self?.clipboardDraft = nil; self?.refreshClipboard() })
            }
            let rows = UIStackView(); rows.axis = .vertical; rows.spacing = 4
            for item in try clipboard?.list(search: clipboardSearch, limit: preferences.safeClipboardLimit) ?? [] {
                let row = UIStackView(); row.axis = .horizontal; row.spacing = 4
                let insert = button(String(item.text.prefix(16))) { [weak self] in
                    guard let self, self.hasFullAccess else { return }
                    self.commitReading(); self.edit { self.textDocumentProxy.insertText(item.text) }; self.recent = nil
                    try? self.clipboard?.markUsed(item.id); self.closeClipboard()
                }
                insert.accessibilityLabel = item.text
                insert.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                row.addArrangedSubview(insert)
                row.addArrangedSubview(button(item.pinned ? "★" : "☆") { [weak self] in self?.mutateClipboard { try $0.togglePin(item.id) } })
                row.addArrangedSubview(button("削除") { [weak self] in self?.mutateClipboard { try $0.remove(item.id) } })
                rows.addArrangedSubview(row)
            }
            content.addArrangedSubview(rows)
        } catch { showStatus(error.localizedDescription); closeClipboard() }
    }
    private func mutateClipboard(_ action: (ClipboardStore) throws -> Void) {
        guard hasFullAccess, preferences.clipboardEnabled, let clipboard else { closeClipboard(); return }
        do { try action(clipboard); refreshClipboard() } catch { showStatus(error.localizedDescription) }
    }
}
