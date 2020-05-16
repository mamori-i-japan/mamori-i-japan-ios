//
//  NavigationProtocol+Trace.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import UIKit

protocol TraceDataUploadAccessable: ModalNavigationProtocol, PushNavigationProtocol {
    func pushToTraceDataUpload()
}

extension TraceDataUploadAccessable {
    func pushToTraceDataUpload() {
        push(to: TraceDataUploadViewController.instantiate())
    }
}

protocol TraceDataUploadCompleteAccessable: PushNavigationProtocol {
    func pushToTraceDataUploadComplete()
}

extension TraceDataUploadCompleteAccessable {
    func pushToTraceDataUploadComplete() {
        push(to: TraceDataUploadCompleteViewController.instantiate())
    }
}

protocol TraceHistoryAccessable: PushNavigationProtocol {
    func pushToTraceHistory()
}

extension TraceHistoryAccessable {
    func pushToTraceHistory() {
        push(to: TraceHistoryViewController.instantiate())
    }
}
