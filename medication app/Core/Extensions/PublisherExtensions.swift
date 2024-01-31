//
//  PublisherExtensions.swift
//  medication app
//
//  Created by Shahzeb Ahmad on 29/11/2023.
//

import Foundation


import Combine

extension Publishers {
    static func debounce<Upstream: Publisher>(
        for dueTime: TimeInterval,
        scheduler: DispatchQueue,
        options: DispatchQueue.SchedulerOptions? = nil,
        upstream: Upstream
    ) -> AnyPublisher<Upstream.Output, Upstream.Failure> where Upstream.Output: Equatable {
        upstream
            .debounce(for: .seconds(dueTime), scheduler: scheduler, options: options)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
