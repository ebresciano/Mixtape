//
//  CloudKitManager.swift
//  Mixtape
//
//  Created by Eva Marie Bresciano on 7/11/16.
//  Copyright © 2016 Eva Bresciano. All rights reserved.
//

import CloudKit
import UIKit

class CloudKitManager {
    
    private let kCreationDate = "creationDate"
    
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
    
    init() {
        checkCloudKitAvailability()
    }
    
    //MARK: User Info Discovery
    
    func fetchLoggedInUserRecord(completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) in
            if let error = error,
                let completion = completion {
                completion(record: nil, error: error)
            }
            if let recordID = recordID,
                let completion = completion {
                self.fetchRecordWithID(recordID, completion: { (record, error) in
                    completion(record: record, error: error)
                })
            }
        }
    }
    
    func fetchUserNameFromRecordID(recordID: CKRecordID, completion: ((firstName: String?, lastName: String?)-> Void)?) {
        let operation = CKDiscoverUserInfosOperation(emailAddresses: nil, userRecordIDs: [recordID])
        
        operation.discoverUserInfosCompletionBlock = { (emailsToUserInfos, userRecordIDsToUserInfos, operationError) -> Void in
            if let userRecordIDsToUserInfos = userRecordIDsToUserInfos,
                let userInfo = userRecordIDsToUserInfos[recordID],
                let completion = completion {
                completion(firstName: userInfo.displayContact?.givenName, lastName: userInfo.displayContact?.familyName)
            } else if let completion = completion {
                completion(firstName: nil, lastName: nil)
            }
        }
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    func fetchAllDiscoverableUsers(completion: ((userInfoRecords: [CKDiscoveredUserInfo]?)-> Void)?){
        
        let operation = CKDiscoverAllContactsOperation()
        
        operation.discoverAllContactsCompletionBlock = { (discoveredUserInfos, error) -> Void in
            
            if let completion = completion {
                completion(userInfoRecords: discoveredUserInfos)
            }
        }
        
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    // MARK: - Fetch Records
    
    //Takes in a RecordID and returns a record.
    func fetchRecordWithID(recordID : CKRecordID, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.fetchRecordWithID(recordID) { (record, error) in
            // Handle Error
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    }
    
    func fetchRecordsWithType(type: String, predicate: NSPredicate = NSPredicate(value: true),  recordFetchedBlock: ((record: CKRecord) -> Void)?, completion: (( records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        // a query is the same thing as a fetch
        let query = CKQuery(recordType: type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = { (fetchedRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            if let recordFetchedBlock = recordFetchedBlock {
                recordFetchedBlock(record: fetchedRecord)
            }
        }
        queryOperation.queryCompletionBlock = { (queryCursor, error) -> Void in
            if let queryCursor = queryCursor {
                //There are more results - go fetch them
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                continuedQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                self.publicDatabase.addOperation(continuedQueryOperation)
            } else {
                //All done getting the records
                if let completion = completion {
                    completion(records: fetchedRecords, error: error)
                }
            }
        }
        
        self.publicDatabase.addOperation(queryOperation)
    }
    
    func fetchCurrentUserRecords(type: String, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        fetchLoggedInUserRecord { (record, error) in
            //TODO Handle Error
            if let record = record {
                let predicate = NSPredicate(format: "%K == %@", argumentArray: ["createUserRecordID", record.recordID])
                self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                    //TODO Handle the Error
                    if let completion = completion {
                        completion(records: records, error: error)
                    }
                })
            }
        }
    }
    
    func fetchRecordsFromDateRange(type: String, fromDate: NSDate, toDate: NSDate, completion: ((records:[CKRecord]?, error: NSError?) -> Void)?) {
        let startDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [kCreationDate, fromDate])
        let endDatePredicate = NSPredicate(format: "%K > %@", argumentArray: [kCreationDate, toDate])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDatePredicate, endDatePredicate])
        
        fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil) { (records, error) in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    }
    
    //MARK: - Delete
    
    func deleteRecordWithID(recordID: CKRecordID, completion: ((recordID: CKRecordID?, error: NSError?) -> Void)?) {
        publicDatabase.deleteRecordWithID(recordID) { (recordID, error) in
            if let completion = completion {
                completion(recordID: recordID, error: error)
            }
        }
    }
    
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((records: [CKRecord]?, recordIDs: [CKRecordID]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.queuePriority = .High
        operation.savePolicy = .IfServerRecordUnchanged
        operation.qualityOfService = .UserInitiated
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            if let completion = completion {
                completion(records: records, recordIDs: recordIDs, error: error)
            }
        }
        publicDatabase.addOperation(operation)
    }
    
    //MARK: - Save and Modify
    
    func saveRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) ->Void)?, completion:((records: [CKRecord]?, error: NSError?) -> Void)?){
        modifyRecords(records, perRecordCompletion: perRecordCompletion) { (records, error) in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    }
    
    func saveRecord(record: CKRecord, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.saveRecord(record) { (record, error) in
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    }
    
    func modifyRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion:
        ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.queuePriority = .High
        operation.savePolicy = .ChangedKeys
        operation.qualityOfService = .UserInteractive
        
        operation.perRecordCompletionBlock = { (record, error) -> Void in
            if let perRecordCompletion = perRecordCompletion {
                perRecordCompletion(record: record, error: error)
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs,  error) -> Void in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
        publicDatabase.addOperation(operation)
    }
    
    func subscribe(type: String, predicate: NSPredicate, subscriptionID: String, contentAvailable: Bool, alertBody: String? = nil, desiredKeys: [String]? = nil, options: CKSubscriptionOptions, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
        
        let subscription = CKSubscription(recordType: type, predicate: predicate, subscriptionID: subscriptionID, options: options)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertBody = alertBody
        notificationInfo.shouldSendContentAvailable = contentAvailable
        notificationInfo.desiredKeys = desiredKeys
        
        subscription.notificationInfo = notificationInfo
        
        publicDatabase.saveSubscription(subscription) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription: subscription, error: error)
            }
        }
    }
    
    func unsubscribe(subscriptionID: String, completion: ((subscriptionID: String?, error: NSError?) -> Void)?) {
        
        publicDatabase.deleteSubscriptionWithID(subscriptionID) { (subscriptionID, error) in
            
            if let completion = completion {
                completion(subscriptionID: subscriptionID, error: error)
            }
        }
    }
    
    func fetchSubscriptions(completion: ((subscriptions: [CKSubscription]?, error: NSError?) -> Void)?) {
        
        publicDatabase.fetchAllSubscriptionsWithCompletionHandler { (subscriptions, error) in
            
            if let completion = completion {
                completion(subscriptions: subscriptions, error: error)
            }
        }
    }
    
    func fetchSubscription(subscriptionID: String, completion: ((subscription: CKSubscription?, error: NSError?) -> Void)?) {
        
        publicDatabase.fetchSubscriptionWithID(subscriptionID) { (subscription, error) in
            
            if let completion = completion {
                completion(subscription: subscription, error: error)
            }
        }
    }
    
    
    //MARK: - CloudKit Permissions
    
    func checkCloudKitAvailability() {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus: CKAccountStatus, error: NSError?) in
            switch accountStatus {
            case .Available:
                print("CloudKit is online")
            default:
                self.handleCloudKitUnavailable(accountStatus, error: error)
            }
        }
    }
    
    func handleCloudKitUnavailable(accountStatus: CKAccountStatus, error: NSError?) {
        var errorText = "Sync is disabled \n"
        if let error = error {
            errorText += error.localizedDescription
        }
        switch accountStatus {
        case .Restricted:
            errorText += "iCloud is not available due to restrictions"
        case .NoAccount:
            errorText += "There is no iCloud account set up. \n You can setup iCloud in the setting app"
        default:
            break
        }
        displayCloudKitNotAvailableError(errorText)
    }
    
    func displayCloudKitNotAvailableError(errorText: String) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alertController = UIAlertController(title: "iCloud Sync Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let AppDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = AppDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        })
        
    }
    //MARK: - CloudKit Discoverability
    
    func requestDiscoverabilityPermission() {
        CKContainer.defaultContainer().statusForApplicationPermission(.UserDiscoverability) { (permissionStatus, error) in
            if permissionStatus == .InitialState {
                CKContainer.defaultContainer().requestApplicationPermission(.UserDiscoverability, completionHandler: { (permissionStatus, error) in
                    self.handleCloudKitPermissionStatus(permissionStatus, error: error)
                })
            } else {
                self.handleCloudKitPermissionStatus(permissionStatus, error: error)
            }
        }
    }
    
    func handleCloudKitPermissionStatus(permissionStatus: CKApplicationPermissionStatus, error: NSError?) {
        if permissionStatus == .Granted {
            print("User Discoverability granted. User may proceed with full access")
        } else {
            var errorText = "Sync is disabled \n"
            if let error = error {
                errorText += error.localizedDescription
            }
            switch permissionStatus {
            case .Denied:
                errorText += "You have denied User Discoverability permissions. You may be unable to use certain features that require User Discoverability"
            case .CouldNotComplete:
                errorText += "Unable to verify User Discoverability permissions. You may have a connectivity issue. Please try again."
            default:
                break
            }
        }
    }
    
    func displayCloudKitPermissionNotGrantedError(errorText: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alertController = UIAlertController(title: "CloudKit Permissions Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let AppDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = AppDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated:  true, completion:  nil)
                
            }
        })
    }
}

