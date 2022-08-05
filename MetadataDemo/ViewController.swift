//
//  ViewController.swift
//  MetadataDemo
//
//  Created by Edward Wellbrook on 05/08/2022.
//

import Cocoa
import Combine

class ViewController: NSViewController {

    @IBOutlet weak var textView: NSTextView!

    private var cancellationToken: Set<AnyCancellable> = []


    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)

        AppDelegate.logs
            .map({ $0.joined(separator: "\n") })
            .assign(to: \.string, on: self.textView)
            .store(in: &self.cancellationToken)
    }

}
