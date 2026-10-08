import UIKit
import KeyboardCore

@MainActor final class KeyboardViewController: UIInputViewController {
    private var composition = Composition()
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
    private let readingLabel = UILabel()
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
        cosmos.tokens = appearance.tokens
        readingLabel.textColor = UIColor(themeHex: appearance.tokens.canvasText)
        func visit(_ parent: UIView) {
            for child in parent.subviews {
                if let key = child as? FlickButton { key.applyTheme(appearance.tokens, strong: strongAppearance) }
                else if let button = child as? UIButton { KeyboardKeyStyle.apply(button, tokens: appearance.tokens, strong: strongAppearance) }
                visit(child)
            }
        }
        visit(bodyStack)
        cosmos.setNeedsDisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        primaryLanguage = "ja-JP"
        view.backgroundColor = .systemBackground
        cosmos.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cosmos)
        NotificationCenter.default.addObserver(self, selector: #selector(applyAppearance), name: UIAccessibility.reduceTransparencyStatusDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyAppearance), name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification, object: nil)
        NSLayoutConstraint.activate([cosmos.leadingAnchor.constraint(equalTo: view.leadingAnchor), cosmos.trailingAnchor.constraint(equalTo: view.trailingAnchor), cosmos.topAnchor.constraint(equalTo: view.topAnchor), cosmos.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        bodyStack.axis = .vertical; bodyStack.spacing = 4
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bodyStack)
        NSLayoutConstraint.activate([
            bodyStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            bodyStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            bodyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bodyStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 4),
            bodyStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -4)
        ])
        widthConstraint = bodyStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -8)
        widthConstraint?.isActive = true
        readingLabel.font = .preferredFont(forTextStyle: .body)
        readingLabel.adjustsFontForContentSizeCategory = true
        readingLabel.accessibilityLabel = "未確定の読み"
        readingLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true
        bodyStack.addArrangedSubview(readingLabel)
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
        bodyStack.addArrangedSubview(candidateScroll)
        grid.axis = .vertical; grid.distribution = .fillEqually; grid.spacing = 5
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
        globe.setTitle("🌐", for: .normal); globe.accessibilityLabel = "次のキーボード"
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        globe.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        toolbar.addArrangedSubview(globe)
        toolbar.addArrangedSubview(button("かな/ABC/123/記号") { [weak self] in
            guard let self else { return }; self.commitReading(); self.mode = (self.mode + 1) % 4; self.buildGrid()
        })
        toolbar.addArrangedSubview(button("←") { [weak self] in self?.moveCursor(-1) })
        toolbar.addArrangedSubview(button("→") { [weak self] in self?.moveCursor(1) })
        let delete = button("⌫") { [weak self] in self?.deleteOne() }
        delete.accessibilityLabel = "1文字削除。長押しで連続削除"
        delete.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(repeatDelete(_:))))
        toolbar.addArrangedSubview(delete)
        toolbar.addArrangedSubview(button("単語削除") { [weak self] in self?.deleteWord() })
        let space = button("空白") { [weak self] in
            guard let self, !self.spaceDidDrag else { self?.spaceDidDrag = false; return }
            self.commitReading(); self.edit { self.textDocumentProxy.insertText(" ") }; self.recent = nil
        }
        space.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragSpace(_:))))
        toolbar.addArrangedSubview(space)
        toolbar.addArrangedSubview(button("確定") { [weak self] in self?.commitReading() })
        toolbar.addArrangedSubview(button("改行") { [weak self] in
            guard let self else { return }; self.commitReading(); self.edit { self.textDocumentProxy.insertText("\n") }; self.recent = nil
        })
        toolbar.addArrangedSubview(button("取消") { [weak self] in self?.cancelComposition() })
        toolbar.addArrangedSubview(button("再変換") { [weak self] in self?.startReconversion() })
        toolbar.addArrangedSubview(button("履歴") { [weak self] in self?.showClipboard() })
        bodyStack.addArrangedSubview(toolbarScroll)
        clipboardPanel.axis = .vertical; clipboardPanel.spacing = 4; clipboardPanel.isHidden = true
        bodyStack.addArrangedSubview(clipboardPanel)
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 340)
        heightConstraint?.priority = .defaultHigh; heightConstraint?.isActive = true
        buildGrid()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferences = (try? PreferencesStore())?.load() ?? .init()
        let themeStore = try? ThemeStore()
        appearance = themeStore?.load(legacy: preferences.theme) ?? .init()
        cosmos.image = themeStore?.imageData(appearance).flatMap { ThemeImageRendering.image($0) }
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
    }
    override func viewWillDisappear(_ animated: Bool) {
        stopActivity(); cancelComposition(); conversion?.close(); closeClipboard()
        recent = nil
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning(); stopActivity(); conversion?.close(); conversion = nil
        closeClipboard(); dictionary = []; composition.reset(); replacing = nil; recent = nil; render()
        cosmos.image = nil
    }
    override func textWillChange(_ textInput: (any UITextInput)?) { if !ownEdit { recent = nil } }
    override func textDidChange(_ textInput: (any UITextInput)?) {
        if !ownEdit { cancelComposition(); recent = nil }
    }

    private func applyLayout() {
        let profile = preferences.profile(landscape: landscape)
        heightConstraint?.constant = profile.height
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
        for case let row as UIStackView in grid.arrangedSubviews { row.spacing = profile.spacing }
    }
    private func button(_ title: String, _ action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal); button.accessibilityLabel = title
        KeyboardKeyStyle.apply(button, tokens: appearance.tokens, strong: strongAppearance)
        button.addAction(UIAction { [weak self, weak button] _ in
            guard let self, let button else { return }
            KeyboardKeyStyle.apply(button, tokens: self.appearance.tokens, pressed: true, strong: self.strongAppearance)
        }, for: .touchDown)
        button.addAction(UIAction { [weak self, weak button] _ in
            guard let self, let button else { return }
            KeyboardKeyStyle.apply(button, tokens: self.appearance.tokens, strong: self.strongAppearance)
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
        for rowIndex in 0..<4 {
            let row = UIStackView(); row.axis = .horizontal; row.distribution = .fillEqually; row.spacing = preferences.profile(landscape: landscape).spacing
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            for key in keys[(rowIndex * 3)..<(rowIndex * 3 + 3)] {
                let control = FlickButton(key: key)
                control.applyTheme(appearance.tokens, strong: strongAppearance)
                control.onCommit = { [weak self] in self?.input($0) }
                row.addArrangedSubview(control)
            }
            grid.addArrangedSubview(row)
        }
    }
    private func input(_ text: String) {
        recent = nil
        if text == "⇧" { uppercase.toggle(); buildGrid(); return }
        if text == "゛小" { composition.modifyPreviousKana(); updateCandidates(); return }
        if mode == 0 {
            if !composition.insert(text) { readingLabel.text = "未確定の読みが上限です。確定してください。"; return }
            updateCandidates()
        } else { edit { textDocumentProxy.insertText(text) } }
    }
    private func updateCandidates() {
        pendingConversion?.cancel(); render()
        guard !composition.reading.isEmpty else { return }
        let reading = composition.reading; let revision = composition.revision
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.composition.revision == revision else { return }
            if self.conversion == nil { self.conversion = AzooKeyConversion() }
            guard let conversion = self.conversion else { return }
            let candidates = conversion.candidates(for: reading, preferences: self.preferences, dictionary: self.dictionary)
            if self.composition.apply(candidates, revision: revision) { self.render() }
        }
        pendingConversion = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04, execute: work)
    }
    private func render() {
        readingLabel.text = composition.reading.isEmpty ? " " : (replacing == nil ? composition.reading : "再変換: " + composition.reading)
        clear(candidateRow)
        let revision = composition.revision
        for choice in composition.candidates {
            candidateRow.addArrangedSubview(button(choice.text) { [weak self] in
                guard let self, self.composition.revision == revision else { return }
                self.commit(choice)
            })
        }
    }
    private func edit(_ action: () -> Void) { ownEdit = true; action(); ownEdit = false }
    private func commitReading() {
        guard !composition.reading.isEmpty else { return }
        commit(.init(composition.reading))
    }
    private func commit(_ choice: ConversionChoice) {
        let reading = composition.reading
        guard !reading.isEmpty else { return }
        var success = true
        edit {
            if let replacing { success = DocumentProxyAdapter(proxy: textDocumentProxy).replace(replacing, with: choice.text) }
            else { textDocumentProxy.insertText(choice.text) }
        }
        if success {
            conversion?.commit(choice, learning: preferences.learningEnabled)
            recent = RecentCommit(reading: reading, text: choice.text, snapshot: DocumentProxyAdapter(proxy: textDocumentProxy).snapshot)
        }
        cancelComposition()
        if !success { readingLabel.text = "入力先が変わったため置換を停止しました。本文を確認してください。"; recent = nil }
    }
    private func cancelComposition() {
        pendingConversion?.cancel(); composition.reset(); replacing = nil; conversion?.reset(); render()
    }
    private func startReconversion() {
        guard experimentalEditingEnabled else { readingLabel.text = "再変換は実機検証後に有効化します。"; return }
        guard composition.reading.isEmpty, let recent, recent.canReplace(in: DocumentProxyAdapter(proxy: textDocumentProxy).snapshot) else {
            readingLabel.text = "安全に再変換できる直前の入力がありません。"; return
        }
        replacing = recent; composition.insert(recent.reading); updateCandidates()
    }
    private func moveCursor(_ offset: Int) {
        recent = nil
        if composition.reading.isEmpty { edit { textDocumentProxy.adjustTextPosition(byCharacterOffset: offset) } }
        else { composition.moveCursor(offset); updateCandidates() }
    }
    private func deleteOne() {
        recent = nil
        if composition.reading.isEmpty { edit { textDocumentProxy.deleteBackward() } }
        else { composition.deleteBackward(); updateCandidates() }
    }
    private func deleteWord() {
        guard experimentalEditingEnabled else { readingLabel.text = "単語削除は実機検証後に有効化します。"; return }
        recent = nil
        guard composition.reading.isEmpty else { cancelComposition(); return }
        var success = false
        edit { success = DocumentProxyAdapter(proxy: textDocumentProxy).deleteWord() }
        if !success { readingLabel.text = "単語境界を確認できません。1文字削除を使ってください。" }
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
            readingLabel.text = "履歴は本体の設定とフルアクセスを有効にしてください。"; return
        }
        if !clipboardPanel.isHidden { closeClipboard(); return }
        stopActivity(); clipboardSearch = ""; clipboardDraft = nil; clipboardPanel.isHidden = false; grid.isHidden = true
        refreshClipboard()
    }
    private func closeClipboard() { clipboardPanel.isHidden = true; grid.isHidden = false; clipboard = nil; clipboardDraft = nil }
    private func refreshClipboard() {
        clear(clipboardPanel)
        guard hasFullAccess, preferences.clipboardEnabled else { closeClipboard(); return }
        do {
            if clipboard == nil { clipboard = try ClipboardStore(writable: true) }
            try clipboard?.prune()
            let actions = UIStackView(); actions.axis = .horizontal; actions.spacing = 4
            actions.addArrangedSubview(button("取り込む") { [weak self] in
                guard let self, self.hasFullAccess else { return }
                // Explicit action only. iOS may request paste permission; no automatic collection.
                let value = UIPasteboard.general.string
                guard let value, ClipboardPolicy.accepts(value) else { self.readingLabel.text = "保存できるテキストがありません（1件16KBまで）。"; return }
                self.clipboardDraft = value; self.refreshClipboard()
            })
            actions.addArrangedSubview(button("読みに一致") { [weak self] in
                guard let self else { return }; self.clipboardSearch = self.composition.reading; self.refreshClipboard()
            })
            actions.addArrangedSubview(button("閉じる") { [weak self] in self?.closeClipboard() })
            clipboardPanel.addArrangedSubview(actions)
            if let draft = clipboardDraft {
                let preview = UILabel(); preview.text = draft; preview.textColor = UIColor(themeHex: appearance.tokens.canvasText); preview.numberOfLines = 2; clipboardPanel.addArrangedSubview(preview)
                clipboardPanel.addArrangedSubview(button("確認した内容を保存") { [weak self] in
                    guard let self, self.hasFullAccess else { return }
                    do { try self.clipboard?.add(draft, limit: self.preferences.safeClipboardLimit); self.clipboardDraft = nil; self.refreshClipboard() }
                    catch { self.readingLabel.text = error.localizedDescription }
                })
                clipboardPanel.addArrangedSubview(button("保存取消") { [weak self] in self?.clipboardDraft = nil; self?.refreshClipboard() })
            }
            let scroll = UIScrollView(); let rows = UIStackView(); rows.axis = .vertical; rows.spacing = 4; rows.translatesAutoresizingMaskIntoConstraints = false
            scroll.addSubview(rows)
            NSLayoutConstraint.activate([
                rows.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor), rows.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                rows.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor), rows.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                rows.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor), scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
            ])
            for item in try clipboard?.list(search: clipboardSearch, limit: preferences.safeClipboardLimit) ?? [] {
                let row = UIStackView(); row.axis = .horizontal; row.spacing = 4
                let insert = button(String(item.text.prefix(16))) { [weak self] in
                    guard let self, self.hasFullAccess else { return }
                    self.commitReading(); self.edit { self.textDocumentProxy.insertText(item.text) }; self.recent = nil
                    try? self.clipboard?.markUsed(item.id); self.closeClipboard()
                }
                insert.accessibilityLabel = item.text
                row.addArrangedSubview(insert)
                row.addArrangedSubview(button(item.pinned ? "★" : "☆") { [weak self] in self?.mutateClipboard { try $0.togglePin(item.id) } })
                row.addArrangedSubview(button("削除") { [weak self] in self?.mutateClipboard { try $0.remove(item.id) } })
                rows.addArrangedSubview(row)
            }
            clipboardPanel.addArrangedSubview(scroll)
        } catch { readingLabel.text = error.localizedDescription; closeClipboard() }
    }
    private func mutateClipboard(_ action: (ClipboardStore) throws -> Void) {
        guard hasFullAccess, preferences.clipboardEnabled, let clipboard else { closeClipboard(); return }
        do { try action(clipboard); refreshClipboard() } catch { readingLabel.text = error.localizedDescription }
    }
}
