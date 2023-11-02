protocol SberpayRouterInput: AnyObject {
    func showBrowser(_ url: URL)
    func showAutopayInfoDetails(title: String, body: String)
    func openUrl(_ url: URL, completion: ((Bool) -> Void)?)
}
