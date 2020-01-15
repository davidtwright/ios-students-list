//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

enum SortOption: Int {
    case firstName
    case lastName
}

class StudentController {
    
    enum StudentError: Error {
        case generic
    }
    
    private var students: [Student] = []
    
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        let bgQueue = DispatchQueue(label: "studentQueue", attributes: .concurrent)
        
        // Everything between the bgQueue brackets will run in a different thread
        bgQueue.async {
            let fm = FileManager.default
            guard let url = self.persistentFileURL else {
                print("Error unable to load from persistent store")
                completion(nil, StudentError.generic)
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let students = try decoder.decode([Student].self, from: data)
                self.students = students
                completion(students, nil)
            } catch {
                print("Error loading student data: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func filter(with trackType: TrackType, sortedBy sorter: SortOption, completion: ([Student]) -> Void) {
        var updatedStudents: [Student]
        
        switch trackType {
        case .iOS:
            updatedStudents = students.filter({ (student) -> Bool in
                return student.course == "iOS"
            })
        case .Web:
            updatedStudents = students.filter { return $0.course == "Web" }
        case .UX:
            updatedStudents = students.filter { $0.course == "UX" }
        default:
            updatedStudents = students
        }
        
        if sorter == .firstName {
            updatedStudents = updatedStudents.sorted { $0.firstName < $1.firstName }
        } else {
            updatedStudents = updatedStudents.sorted { $0.lastName < $1.lastName }
        }
        
        completion(updatedStudents)
    }
}
