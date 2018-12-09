//
//  Movie.swift
//  RentoMovie
//
//  Created by Shailesh.Chandavar on 07/12/18.
//  Copyright © 2018 Shailesh.Chandavar. All rights reserved.
//

import Foundation

// Movie represents info of movie and info will be shown in MovieListViewController.
class Movie : Codable {
    var posterPath: String?
    var title = ""
    var adult = false
    var voteAverage: Float = 0.0
    var synopsisShown: Bool = false
    var releaseDate = ""
    var overView = ""

    private enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case title
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case overView = "overview"
        case adult
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.voteAverage = try container.decodeIfPresent(Float.self, forKey: .voteAverage) ?? 0.0
        self.releaseDate = (try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? "")
        self.overView = try container.decodeIfPresent(String.self, forKey: .overView) ?? ""
        self.adult = try container.decodeIfPresent(Bool.self, forKey: .adult) ?? false
    }
    
    func imageURL() -> URL? {
        var baseURL = "http://image.tmdb.org/t/p/w92"
        baseURL.append(posterPath ?? "")
        return URL(string: baseURL)
        
    }
    
    func certificate() -> String {
        return "Certificate: " + (adult ? "A" : "U/A")
    }
    
    func releaseDateDescription() -> String {
        return "Release Date: " + releaseDate
    }
}
