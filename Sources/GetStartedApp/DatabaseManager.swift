/*
* Copyright IBM Corporation 2017
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import CloudEnvironment
import CouchDB
import LoggerAPI
import Dispatch
import Foundation

class DatabaseManager {

  private var db: Database? = nil
  private let dbClient: CouchDBClient
  private let semaphore = DispatchSemaphore(value: 1)
  private let dbName: String

  init?(dbName: String, credentials: CloudantCredentials?) {
    self.dbName = dbName

    // Get database connection details...
    guard let credentials = credentials else {
      Log.warning("Could not load credentials for Cloudant db.")
      return nil
    }

    let connectionProperties = ConnectionProperties(host: credentials.host,
      port: Int16(credentials.port),
      secured: true,
      username: credentials.username,
    password: credentials.password)
    self.dbClient = CouchDBClient(connectionProperties: connectionProperties)
    Log.info("Found and loaded credentials for Cloudant database.")
  }

  public func getDatabase(callback: @escaping (Database?, NSError?) -> ()) -> Void {
    semaphore.wait()

    if let database = db {
      semaphore.signal()
      callback(database, nil)
      return
    }

    //dbClient.dbExists(dbName) { [weak self] (exists: Bool, error: NSError?) in
    dbClient.dbExists(dbName) { (exists: Bool, error: NSError?) in
      if exists {
        Log.info("Database '\(self.dbName)' found.")
        self.db = self.dbClient.database(self.dbName)
        self.semaphore.signal()
        callback(self.db, error)
      } else {
        self.dbClient.createDB(self.dbName) { (db: Database?, error: NSError?) in
          if let _ = db, error == nil {
            self.db = db
            Log.info("Database '\(self.dbName)' created.")
          } else {
            Log.error("Something went wrong... database '\(self.dbName)' was not created.")
          }
          self.semaphore.signal()
          callback(self.db, error)
        }
      }
    }
  }

}
