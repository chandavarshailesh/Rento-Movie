//
//  RentoMovieTests.swift
//  RentoMovieTests
//
//  Created by Shailesh.Chandavar on 09/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import XCTest
import UIKit

class RentoMovieTests: XCTestCase {
    
    let result = [["vote_count":2040,
                   "id":332562,
                   "video":false,"vote_average":7.4,
                   "title":"A Star Is Born","popularity":98.306,
                   "poster_path":"wrFpXMNBRj2PBiN4Z5kix51XaIZ.jpg",
                   "original_language":"en",
                   "original_title":"A Star Is Born",
                   "genre_ids":[18,10402,10749],
                   "adult":false,
                   "overview":"Seasoned musician",
                   "release_date":"2018-10-03"], [:]]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMovieListPresenter() {
        let moviePresenter = MovieListPresenter()
        let testCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        moviePresenter.configureCollectionView(collectionView: testCollectionView, containerController: UIViewController())
        
        XCTAssert(moviePresenter.minCellHeight == 150, "Collectionview presenter configurationFailed for minCellHeight")
        
        if let flowLayout = testCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            XCTAssert(flowLayout.minimumInteritemSpacing == 10, "Collectionview presenter configurationFailed for minimumInteritemSpacing")
            XCTAssert(flowLayout.minimumLineSpacing == 20, "Collectionview presenter configuration Failed for minimumLineSpacing")
            
            XCTAssert(flowLayout.sectionInset == UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10), "Collectionview presenter configuration Failed for sectionInset")
        }
        
        
        let requestExpection = expectation(description: "Get response from url method expection")
        moviePresenter.fetchMovieList { (movie) in
            XCTAssertNotNil(movie, "respose shouldn't be nil, get response from url method failed")
            requestExpection.fulfill()
            let cellHeight = moviePresenter.cellHeightForCompleteSynopsis(movie: movie?.first ?? Movie(), cellWidth: 300)
            
            XCTAssert(Int(cellHeight) == Int(294.5), "Cell Height Calculation Failure")
            
        }
        waitForExpectations(timeout: 60.0, handler: nil)
        
        
    }
    
    
    //MARK: Utility test
    
    func testUtility() {
        //localizatipon test
        XCTAssert("testString".localized() == "testString", "localization failure") //app doesn't have localised strings
        
        //UIFont test
        let stringHeight = UIFont.systemFont(ofSize: 12.0).sizeOfString(strings: ["hello"], constrainedToWidth: 24.0)
        XCTAssert(Int(stringHeight) == Int(28.6), "String Height Calculation Failure")
        
        //Data Extension test
        XCTAssertNotNil(Data.documentDirectoryPath(), "documentDirectoryPath method failure in Data extension")
        
        if let testData = "testString".data(using: .utf8) {
            testData.storeDataInFile(fileName: "testData")
            let retrievedData = Data.loadDataFromFile(fileName: "testData") ?? Data()
            
            
            XCTAssert((String(data: retrievedData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) ?? "") == "testString", "loadDataFromFile Failure")
        }
        
        
    }
    
    //MARK: RequestManager test
    
    func testAPIURL() {
        XCTAssertNotNil(APIURL.movieListAPI.requestWithPage(page: 0), "URL request creation failed")
    }
    
    func testRequestManagerError() {
        XCTAssertEqual(RequestManagerError.noData.localizedDescription, "We are facing some technical issue, our team is working on it. Please try after sometime.", "Request manager error creation failed")
    }
    
    func testGetResponseForURL() {
        let requester = RequestManager.requester()
        let reuquestExpection = expectation(description: "Get response from url method expection")
        
        if let urlRequest =  APIURL.movieListAPI.requestWithPage(page: 0) {
            
            requester.getResponseForURL(urlRequest: urlRequest) { (dictionary, error) in
                XCTAssertNotNil(dictionary, "respose shouldn't be nil, get response from url method failed")
                XCTAssertNil(error, "error shouldn't come, get response from url method failed")
                reuquestExpection.fulfill()
            }
        }
        
        waitForExpectations(timeout: 60.0, handler: nil)
        
        
        if let invalidURL = URL(string: "http://invalidurl") {
            let invalidReuquestExpection = expectation(description: "Get response from invalid url method expection")
            
            requester.getResponseForURL(urlRequest: URLRequest(url: invalidURL)) { (dictionary, error) in
                XCTAssertNil(dictionary, "respose should be nil, get response from url method failed")
                XCTAssertNotNil(error, "error should come, get response from url method failed")
                invalidReuquestExpection.fulfill()
            }
            waitForExpectations(timeout: 60.0, handler: nil)
        }
    }
    
    //MARK: test Movies Model
    
    func testMovie() {
        let movie = Movie()
        movie.adult = true
        movie.posterPath = "/testPath"
        movie.releaseDate = "12/12/12"
        
        
        XCTAssert(movie.imageURL() == URL(string: "http://image.tmdb.org/t/p/w92/testPath"), "Image URL function failure")
        XCTAssert(movie.certificate() == "Certificate: A", "certificate function failure")
        movie.adult = false
        XCTAssert(movie.certificate() == "Certificate: U/A", "certificate function failure")
        XCTAssert(movie.releaseDateDescription() == "Release Date: 12/12/12", "String Height Calculation Failure")
        
        let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
        if let movies = try? JSONDecoder().decode([Movie].self, from: data!) {
            XCTAssertNotNil(movies, "Movie object vreation failure by codable")
            
        }
        
    }

}
