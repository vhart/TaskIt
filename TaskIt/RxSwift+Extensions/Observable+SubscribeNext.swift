import RxSwift

extension Observable {
    func subscribeNext(onNext: @escaping (Element) -> Void) -> Disposable {
        return self.subscribe(onNext: onNext,
                              onError: nil,
                              onCompleted: nil,
                              onDisposed: nil)
    }
}
