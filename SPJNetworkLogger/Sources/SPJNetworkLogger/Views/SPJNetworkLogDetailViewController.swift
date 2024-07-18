//
//  SPJNetworkLogDetailViewController.swift
//  POC
//
//  Created by Shine PJ on 15/07/2024.
//

import UIKit

class SPJNetworkLogDetailViewController: UIViewController, UITableViewDataSource {
    var log: SPJNetworkLog?
    @IBOutlet weak var detailTableView: UITableView!

    @IBAction func btnBackClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
    }

    @IBAction func btnShareClick(_ sender: Any) {
        if let pdfData = createPDF() {
            let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return log == nil ? 0 : 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SPJLogDetailTableViewCell") as? SPJLogDetailTableViewCell else { return SPJLogDetailTableViewCell() }
        guard let log = log else { return cell }

        switch indexPath.row {
        case 0:
            cell.titleLabel?.text = "URL"
            cell.descLabel?.text = log.url
        case 1:
            cell.titleLabel?.text = "Method"
            cell.descLabel?.text = log.method
        case 2:
            cell.titleLabel?.text = "Request Headers"
            cell.descLabel?.text = log.requestHeaders
        case 3:
            cell.titleLabel?.text = "Request Body"
            cell.descLabel?.text = log.requestBody == nil ? "nil" : String(data: log.requestBody!, encoding: .utf8) ?? "binary data"
        case 4:
            cell.titleLabel?.text = "Status Code"
            cell.descLabel?.text = "\(log.statusCode)"
        case 5:
            cell.titleLabel?.text = "Response Headers"
            cell.descLabel?.text = log.responseHeaders
        case 6:
            cell.titleLabel?.text = "Response Body"
            cell.descLabel?.text = log.responseBody == nil ? "nil" : String(data: log.responseBody!, encoding: .utf8) ?? "binary data"
        case 7:
            cell.titleLabel?.text = "Response Time"
            cell.descLabel?.text = "\(log.responseTime) seconds"
        default:
            cell.titleLabel?.text = ""
            cell.descLabel?.text = ""
        }
        return cell
    }

    private func createPDF() -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "SPJNetworkLogger",
            kCGPDFContextAuthor: "YourName",
            kCGPDFContextTitle: "Network Log"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            context.beginPage()

            let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
            let bodyFont = UIFont.systemFont(ofSize: 12, weight: .regular)

            var yOffset: CGFloat = 20

            func drawText(_ text: String, font: UIFont, yOffset: inout CGFloat) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font
                ]
                let attributedText = NSAttributedString(string: text, attributes: attributes)
                let textRect = CGRect(x: 20, y: yOffset, width: pageRect.width - 40, height: attributedText.size().height)
                attributedText.draw(in: textRect)
                yOffset += textRect.height + 10
            }

            drawText("Network Log", font: titleFont, yOffset: &yOffset)
            drawText("URL: \(log?.url ?? "N/A")", font: bodyFont, yOffset: &yOffset)
            drawText("Method: \(log?.method ?? "N/A")", font: bodyFont, yOffset: &yOffset)
            drawText("Request Headers: \(log?.requestHeaders ?? "N/A")", font: bodyFont, yOffset: &yOffset)
            drawText("Request Body: \(log?.requestBody == nil ? "nil" : String(data: log!.requestBody!, encoding: .utf8) ?? "binary data")", font: bodyFont, yOffset: &yOffset)
            drawText("Status Code: \(log?.statusCode ?? 0)", font: bodyFont, yOffset: &yOffset)
            drawText("Response Headers: \(log?.responseHeaders ?? "N/A")", font: bodyFont, yOffset: &yOffset)
            drawText("Response Body: \(log?.responseBody == nil ? "nil" : String(data: log!.responseBody!, encoding: .utf8) ?? "binary data")", font: bodyFont, yOffset: &yOffset)
            drawText("Response Time: \(log?.responseTime ?? 0) seconds", font: bodyFont, yOffset: &yOffset)
        }

        return data
    }
}
