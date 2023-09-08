//
//  ArrayExtension.swift
//  ReCamV5
//
//  Created by Park on 2020/3/18.
//  Copyright © 2020 Wade. All rights reserved.
//

import UIKit

extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        return sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}

extension Array where Element: Equatable {
    
    mutating func remove(_ object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
    
    func indexOf(_ object: Element) -> Int? {
        if let index = firstIndex(of: object) {
            return index
        }
        return nil
    }
    
    func random() -> Element {
        return self[Int(arc4random())%count]
    }
}

extension Array {
    
    func any(where predicate: (Element) -> Bool) -> Bool {
      for element in self {
        if predicate(element) {
          return true
        }
      }
      return false
    }
    
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}

extension Array {
    mutating func safeAppend(_ object: Iterator.Element?) {
        if let o = object {
            self.append(o)
        } else {
            printLog("Warning! Array:\(self) add an nil element")
        }
    }
    
    subscript (safety index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

extension Sequence where Iterator.Element == Int {
    
    private func removeRepeats()->[Int]{
        let set = Set(self)
        return Array(set).sorted {$0>$1}
    }

    private func countFor(value:Int)->Int{
        return filter {$0 == value}.count
    }

    func sortByRepeatCount()->[Iterator.Element]{
        var wets = [[Int]]()
        let clearedAry = removeRepeats()
        for i in clearedAry{
            wets.append([i,countFor(value: i)])
        }

        wets = wets.sorted {
            $0[1] > $1[1]
        }

        var result = [Int]()
        for x in wets{
            let i = x[0]
            let count = x[1]
            for _ in 0..<count{
                result.append(i)
            }
        }

        return result
    }
}

