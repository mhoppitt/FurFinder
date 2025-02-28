//
//  BreedsService.swift
//  FurFinder
//
//  Created by Matt Hoppitt on 6/1/2025.
//

import AWSDynamoDB
import AWSSNS
import AWSS3

public class BreedsService {
    let tableName = "FurFinder-Breeds"
    let bucketName = "fur-finder-bucket"
    
    public init() {
        let configuration = AWSServiceConfiguration(region: .APSoutheast2, credentialsProvider: AWSStaticCredentialsProvider(accessKey: ACCESS_KEY, secretKey: SECRET_KEY))
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func generateID() -> String {
        return UUID().uuidString
    }
    
    func getPresignedUrl(breedName: String) async throws -> String {
        let awsS3GetPreSignedURLRequest: AWSS3GetPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        awsS3GetPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
        awsS3GetPreSignedURLRequest.key = breedName
        awsS3GetPreSignedURLRequest.bucket = bucketName
        awsS3GetPreSignedURLRequest.expires = Date(timeIntervalSinceNow: TimeInterval(900))
        var result: String?
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(awsS3GetPreSignedURLRequest).continueWith { task in
            result = task.result?.absoluteString
        }
        return result ?? ""
    }
    
    func uploadToS3(withImage image: UIImage, key: String) async {
        let data: Data = image.pngData()!
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in
            DispatchQueue.main.async(execute: {
                // Update a progress bar
            })
        }

        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
            })
        }

        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data, bucket: bucketName, key: key, contentType: "png", expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
                if let error = task.error {
                    print("Error : \(error.localizedDescription)")
                }

                if task.result != nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                    if let absoluteString = publicURL?.absoluteString {
                        // Set image with URL
                        print("Image URL : ",absoluteString)
                    }
                }
                return nil
            }
    }
    
    func deleteFromS3(fileName: String) async {
        // Create an S3 Delete Object Request
        let deleteRequest = AWSS3DeleteObjectRequest()
        deleteRequest?.bucket = bucketName
        deleteRequest?.key = fileName
        
        let s3 = AWSS3.default()
            
        // Perform the delete operation
        s3.deleteObject(deleteRequest!).continueWith { task -> Any? in
            if let error = task.error {
                // Handle error
                print(error)
            }
            return nil
        }
    }
    
    func getBreeds() async throws -> [FurFinderBreed] {
        let dynamoDB = AWSDynamoDB.default()
        
        guard let query = AWSDynamoDBScanInput() else {
            return []
        }
        query.tableName = tableName
        
        let response = try await dynamoDB.scan(query)
        
        var breedList: [FurFinderBreed] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        
        for record in response.items.unsafelyUnwrapped {
            let id: String = record["id"]!.s.unsafelyUnwrapped
            let breedName: String = record["breedName"]!.s.unsafelyUnwrapped
            let isCapturedString: String = record["isCaptured"]!.boolean!.stringValue
            let isCaptured = isCapturedString == "1" ? true : false
            let detailsId: String = (record["details"]!.m!["id"]?.s.unsafelyUnwrapped)!
            let name: String = (record["details"]!.m!["name"]?.s.unsafelyUnwrapped)!
            let age: String = (record["details"]!.m!["age"]?.s.unsafelyUnwrapped)!
            let funFact: String = (record["details"]!.m!["funFact"]?.s.unsafelyUnwrapped)!
            let sex: String = (record["details"]!.m!["sex"]?.s.unsafelyUnwrapped)!
            let location: String = (record["details"]!.m!["location"]?.s.unsafelyUnwrapped)!
            let dateString: String = (record["details"]!.m!["dateTaken"]?.s.unsafelyUnwrapped)!
            
            let date = dateFormatter.date(from: dateString) ?? Date()
            
            let details = DogDetails(id: detailsId, name: name, dateTaken: date, age: age, funFact: funFact, sex: sex, location: location)
            
            let breed = FurFinderBreed(id: id, breedName: breedName, isCaptured: Bool(isCaptured) , details: details)
            breedList.append(breed)
        }
        let sortedBreedList = breedList.sorted {
            $0.id < $1.id
        }
        return sortedBreedList
    }
    
    func addBreed(breed: FurFinderBreed) async throws {
        let dynamoDB = AWSDynamoDB.default()
        guard let id = AWSDynamoDBAttributeValue() else {
            return print("Error setting id")
        }
        id.s = breed.id
        
        guard let isCaptured = AWSDynamoDBAttributeValue() else {
            return print("Error setting isCaptured")
        }
        isCaptured.boolean = breed.isCaptured as NSNumber
        let updatedIsCaptured: AWSDynamoDBAttributeValueUpdate = AWSDynamoDBAttributeValueUpdate()
        updatedIsCaptured.value = isCaptured
        updatedIsCaptured.action = AWSDynamoDBAttributeAction.put
        
        guard let detailsId = AWSDynamoDBAttributeValue() else {
            return print("Error setting detailsId")
        }
        detailsId.s = breed.details.id
        
        guard let age = AWSDynamoDBAttributeValue() else {
            return print("Error setting age")
        }
        age.s = breed.details.age
        
        guard let dateTaken = AWSDynamoDBAttributeValue() else {
            return print("Error setting dateTaken")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(abbreviation: TimeZone.current.identifier)
        let dateTakenString = dateFormatter.string(from: breed.details.dateTaken)
        dateTaken.s = dateTakenString
        
        guard let funFact = AWSDynamoDBAttributeValue() else {
            return print("Error setting funFact")
        }
        funFact.s = breed.details.funFact
        
        guard let location = AWSDynamoDBAttributeValue() else {
            return print("Error setting location")
        }
        location.s = breed.details.location
        
        guard let name = AWSDynamoDBAttributeValue() else {
            return print("Error setting name")
        }
        name.s = breed.details.name

        guard let sex = AWSDynamoDBAttributeValue() else {
            return print("Error setting sex")
        }
        sex.s = breed.details.sex
        
        guard let updatedInput = AWSDynamoDBUpdateItemInput() else {
            return print("Error setting tableName")
        }
        updatedInput.tableName = self.tableName
        updatedInput.key = ["id": id]
        
        guard let details = AWSDynamoDBAttributeValue() else {
            return print("Error setting details")
        }
        details.m = [
            "id": detailsId,
            "age": age,
            "dateTaken": dateTaken,
            "funFact": funFact,
            "location": location,
            "name": name,
            "sex": sex
        ]
        let updatedDetails: AWSDynamoDBAttributeValueUpdate = AWSDynamoDBAttributeValueUpdate()
        updatedDetails.value = details
        updatedDetails.action = AWSDynamoDBAttributeAction.put
        
        updatedInput.attributeUpdates = [
            "isCaptured": updatedIsCaptured,
            "details": updatedDetails
        ]
        updatedInput.returnValues = AWSDynamoDBReturnValue.updatedNew

        try await dynamoDB.updateItem(updatedInput)
    }
    
    func deleteBreed(breed: FurFinderBreed) async throws {
        try await addBreed(breed: FurFinderBreed(id: breed.id, breedName: breed.breedName, isCaptured: false, details: DogDetails(id: "", name: "", dateTaken: Date(), age: "", funFact: "", sex: "", location: "")))
        await deleteFromS3(fileName: breed.id)
    }
    
    func getCompletionRate() async throws -> Completion {
        let allBreeds: [FurFinderBreed] = try await getBreeds()
        // Filter tasks where isCompleted is true
        let capturedBreeds = allBreeds.filter { breed in
            breed.isCaptured == true
        }
            
        // Calculate the percentage
        let totalBreeds = allBreeds.count
        guard totalBreeds > 0 else {
            return Completion(completionRate: "0", completed: 0, total: 0)
        } // Avoid division by zero
            
        let completionPercentage = (Double(capturedBreeds.count) / Double(totalBreeds)) * 100.0
        let completionRate = String(format: "%.2f", completionPercentage)
        return Completion(completionRate: completionRate, completed: capturedBreeds.count, total: totalBreeds)
    }
}
