//
//  NavigationProtocol+Trace.swift
//  TraceCovid19
//
//  Created by yosawa on 2020/04/30.
//

import UIKit

protocol TraceDataUploadAccessable: ModalNavigationProtocol, PushNavigationProtocol {
    func modalToTraceDataUpload()
    func pushToTraceDataUpload()
}

extension TraceDataUploadAccessable {
    func modalToTraceDataUpload() {
        present(to: TraceDataUploadViewController.instantiate())
    }

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
