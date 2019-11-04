protocol Debouncing {
    func debounce(_ action: @escaping () -> Void)
    func cancel()
}
