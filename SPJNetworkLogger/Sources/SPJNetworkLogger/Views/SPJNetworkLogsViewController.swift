//
//  SPJNetworkLogsViewController.swift
//  POC
//
//  Created by Shine PJ on 15/07/2024.
//

import UIKit

class SPJNetworkLogsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    private var logs: [SPJNetworkLog] = []
    private var filteredLogs: [SPJNetworkLog] = []
    
    private var selectedLog: SPJNetworkLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail", let selectedLog = self.selectedLog {
            if let destinationVC = segue.destination as? SPJNetworkLogDetailViewController {
                destinationVC.log = selectedLog
            }
        }
    }
    @IBAction func btnCloseLogClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func btnMenuClick(_ sender: Any) {
        clearLogs()
    }

    private func setupUI() {
        title = "Network Logs"
    }

    private func fetchData() {
        logs = SPJNetworkLogger.shared.getLogs().sorted(by: { $0.timestamp > $1.timestamp })
        filteredLogs = logs
        listTableView.reloadData()
        print("Fetched logs: \(logs.count) entries")
    }

    private func clearLogs() {
        SPJNetworkLogger.shared.clearLogs()
        fetchData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SPJLogListTableViewCell") as? SPJLogListTableViewCell else { return SPJLogListTableViewCell() }
        let log = filteredLogs[indexPath.row]
        cell.urlLabel.text = log.url
        cell.retuestMethodLabel.text = log.method
        cell.responseTimeLabel.text = String(log.responseTime)
        cell.statusCodeLabel.text = String(log.statusCode)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLog = filteredLogs[indexPath.row]
        self.performSegue(withIdentifier: "detail", sender: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredLogs = logs
        } else {
            filteredLogs = logs.filter { $0.url.contains(searchText) }
        }
        listTableView.reloadData()
    }
}
