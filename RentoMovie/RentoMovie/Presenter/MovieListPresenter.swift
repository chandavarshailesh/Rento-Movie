//
//  MovieListPresenter.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import Foundation
import UIKit

//MovieListPresenter is acts as a presenter and helps MovieListViewController poupulate
// the movie info.
class MovieListPresenter {
    
    init() {}
    
    let minCellHeight: CGFloat = 150.0
    let minimumSpacing: CGFloat = 10.0
    let padding: CGFloat = 10.0
    var pageIndex = 0
    var movies = [Movie]()
    var apiSetupCompleted = false
    var cachedCellSize: CGSize?
    var reloadingInProgress = false
    weak var containerController: UIViewController?
    
    var completionHandler: (([Movie]?) -> ())?
    
    func configureCollectionView(collectionView: UICollectionView, containerController: UIViewController) {
        self.containerController =  containerController
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        
        flowLayout.minimumInteritemSpacing = minimumSpacing
        flowLayout.minimumLineSpacing = 2 * minimumSpacing
        flowLayout.sectionInset = UIEdgeInsets(top: 2 * padding, left: padding, bottom: 2 * padding, right: padding)
    }
    
    func sizeForItemInTraitCollection(traitCollection: UIUserInterfaceSizeClass, screenWidth: CGFloat, movieInfo: Movie?) -> CGSize {
        if let cachedCellSize = cachedCellSize, !(movieInfo?.synopsisShown ?? false){
            return cachedCellSize
        }
        
        var numberOfDivision = 0
        
        if traitCollection == .compact,  !UIApplication.shared.statusBarOrientation.isLandscape {
            numberOfDivision = 1
        } else {
            numberOfDivision = (UIDevice.current.userInterfaceIdiom == .pad) ? 3 : 2
        }
        
        var cellsize = CGSize(width: ((screenWidth - (CGFloat(numberOfDivision + 1) * padding)) / CGFloat(numberOfDivision)), height: minCellHeight)
        cachedCellSize = cellsize
       
        if let movieInfo = movieInfo, movieInfo.synopsisShown {
            cellsize.height = cellHeightForCompleteSynopsis(movie: movieInfo, cellWidth: cellsize.width)
        }
        
        return cellsize
    }
    
    func cellHeightForCompleteSynopsis(movie: Movie, cellWidth: CGFloat) -> CGFloat {
        let availableWidth = cellWidth - 120.0
    
        var proposedHeight = UIFont.boldSystemFont(ofSize: 15.0).sizeOfString(strings: [movie.title], constrainedToWidth: Double(availableWidth))
        
        proposedHeight =  proposedHeight + UIFont.boldSystemFont(ofSize: 12.0).sizeOfString(strings: [movie.releaseDateDescription(), movie.overView, movie.certificate()], constrainedToWidth: Double(availableWidth))
        
        return  max(minCellHeight, proposedHeight + 62)
    }
    
    func fetchMovieList(completionHandler: @escaping ([Movie]?) -> ()) {
        guard !reloadingInProgress else {return}
        
        if !hasConnectivity() {
            completionHandler(loadMoviesFromCache())
            return
        }
    
        self.completionHandler = completionHandler
        let propposedPageIndex = pageIndex + 1
        if let movieAPIRequest = APIURL.movieListAPI.requestWithPage(page: propposedPageIndex) {
            apiSetupCompleted = false
            RequestManager.requester().getResponseForURL(urlRequest: movieAPIRequest) {[weak self] (reponseDictionary, error) in
                guard let `self` = self else {return}
                if let error = error {
                    self.showErrorAlert(error: error as NSError)
                } else if let reponseDictionary = reponseDictionary {
                    let result = reponseDictionary["results"] as? [[String: Any]] ?? [[String: Any]]()
                    self.pageIndex = propposedPageIndex
                    
                    let data = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                    if let movies = try? JSONDecoder().decode([Movie].self, from: data!) {
                        self.movies =  self.movies + (movies)
                    }
                    self.updateCacheWithMovieList(movies: self.movies)
                    completionHandler(self.movies)
                   
                }
                self.apiSetupCompleted = true
            }
        }
    }
    
    private func updateCacheWithMovieList(movies: [Movie]) {
        
        if let encodedMovies = try? JSONEncoder().encode(movies) {
            encodedMovies.storeDataInFile(fileName: "movies")
        }
    }
    
    private func loadMoviesFromCache() -> [Movie]? {
        var movies: [Movie]?
        if let data = Data.loadDataFromFile(fileName: "movies") {
             movies = try? JSONDecoder().decode([Movie].self, from: data)
        }
      return movies
    }
    
    private func hasConnectivity() -> Bool {
      return [Reachability.Connection.wifi,Reachability.Connection.cellular].contains(Reachability()?.connection)
    }
    
    //show alert
    private func showErrorAlert(error: NSError) {
        
        let exitAction = UIAlertAction(title: "Exit".localized(), style: .cancel) { [weak self] (exit) in
            guard let `self` = self else {return}
            self.exitTheApp()
        }
        
        let retryAction = UIAlertAction(title: "Retry".localized(), style: .default) {[weak self] (retryAction) in
            guard let `self` = self else {return}
            guard let completionHandler = self.completionHandler else {return}
            
            self.fetchMovieList(completionHandler: completionHandler)
        }
        
        let localizedDescription = (error as? RequestManagerError)?.localizedDescription ?? error.localizedDescription 
        
        let errorAlert = UIAlertController(title: "Oops!".localized(), message: localizedDescription, preferredStyle: .alert)
        
        errorAlert.addAction(exitAction)
        errorAlert.addAction(retryAction)
        DispatchQueue.main.async {
            self.containerController?.present(errorAlert, animated: true, completion: nil)
        }
        
    }
    
    
    private func exitTheApp() {
        exit(0)
    }
    
}
