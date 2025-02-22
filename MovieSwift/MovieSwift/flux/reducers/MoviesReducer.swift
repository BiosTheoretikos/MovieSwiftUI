//
//  MoviesStateReducer.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 06/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import Foundation
import SwiftUIFlux

func moviesStateReducer(state: MoviesState, action: Action) -> MoviesState {
    var state = state
    switch action {
    case let action as MoviesActions.SetPopular:
        if action.page == 1 {
            state.popular = action.response.results.map{ $0.id }
        } else {
            state.popular.append(contentsOf: action.response.results.map{ $0.id })
        }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetTopRated:
        if action.page == 1 {
            state.topRated = action.response.results.map{ $0.id }
        } else {
            state.topRated.append(contentsOf: action.response.results.map{ $0.id })
        }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetUpcoming:
        if action.page == 1 {
            state.upcoming = action.response.results.map{ $0.id }
        } else {
            state.upcoming.append(contentsOf: action.response.results.map{ $0.id })
        }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetNowPlaying:
        if action.page == 1 {
            state.nowPlaying = action.response.results.map{ $0.id }
        } else {
            state.nowPlaying.append(contentsOf: action.response.results.map{ $0.id })
        }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetDetail:
        state.movies[action.movie] = action.response
        
    case let action as MoviesActions.SetRecommended:
        state.recommended[action.movie] = action.response.results.map{ $0.id }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetSimilar:
        state.similar[action.movie] = action.response.results.map{ $0.id }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetSearch:
        if action.page == 1 {
            state.search[action.query] = action.response.results.map{ $0.id }
        } else {
            state.search[action.query]?.append(contentsOf: action.response.results.map{ $0.id })
        }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetSearchKeyword:
        state.searchKeywords[action.query] = action.response.results
        
    case let action as MoviesActions.AddToWishlist:
        state.wishlist.insert(action.movie)
        
        var meta = state.moviesUserMeta[action.movie] ?? MovieUserMeta()
        meta.dateAddedToWishlist = Date()
        state.moviesUserMeta[action.movie] = meta
        
    case let action as MoviesActions.RemoveFromWishlist:
        state.wishlist.remove(action.movie)
        state.moviesUserMeta[action.movie]?.dateAddedToWishlist = nil
        
    case let action as MoviesActions.AddToSeenList:
        state.seenlist.insert(action.movie)
        
        var meta = state.moviesUserMeta[action.movie] ?? MovieUserMeta()
        meta.dateAddedToSeenList = Date()
        state.moviesUserMeta[action.movie] = meta
        
    case let action as MoviesActions.RemoveFromSeenList:
        state.seenlist.remove(action.movie)
        state.moviesUserMeta[action.movie]?.dateAddedToSeenList = nil
        
    case let action as MoviesActions.AddMovieToCustomList:
        state.customLists[action.list]?.movies.append(action.movie)
        
    case let action as MoviesActions.AddMoviesToCustomList:
        state.customLists[action.list]?.movies.append(contentsOf: action.movies)
        
    case let action as MoviesActions.RemoveMovieFromCustomList:
        state.customLists[action.list]?.movies.removeAll{ $0 == action.movie }
        
    case let action as MoviesActions.SetMovieForGenre:
        state.withGenre[action.genre.id] = action.response.results.map{ $0.id }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetRandomDiscover:
        if state.discover.isEmpty {
            state.discover = action.response.results.map{ $0.id }
        } else if state.discover.count < 10 {
            state.discover.insert(contentsOf: action.response.results.map{ $0.id }, at: 0)
        }
        state = mergeMovies(movies: action.response.results, state: state)
        state.discoverFilter = action.filter
        
    case let action as MoviesActions.SetMovieReviews:
        state.reviews[action.movie] = action.response.results
        
    case let action as MoviesActions.SetMovieWithCrew:
        state.withCrew[action.crew] = action.response.results.map{ $0.id }
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.SetMovieWithKeyword:
        if action.page == 1 {
            state.withKeywords[action.keyword] = action.response.results.map{ $0.id }
        } else {
            state.withKeywords[action.keyword]?.append(contentsOf: action.response.results.map{ $0.id })
        }
        
        state = mergeMovies(movies: action.response.results, state: state)
        
    case let action as MoviesActions.AddCustomList:
        state.customLists[action.list.id] = action.list
        
    case let action as MoviesActions.EditCustomList:
        if var list = state.customLists[action.list] {
            if let cover = action.cover {
                list.cover = cover
            }
            if let title = action.title {
                list.name = title
            }
            state.customLists[action.list] = list
        }
        
    case let action as MoviesActions.RemoveCustomList:
        state.customLists[action.list] = nil
        
    case _ as  MoviesActions.PopRandromDiscover:
        _ = state.discover.popLast()
    case let action as  MoviesActions.PushRandomDiscover:
        state.discover.append(action.movie)
        
    case _ as  MoviesActions.ResetRandomDiscover:
        state.discoverFilter = nil
        state.discover = []
        
    case let action as MoviesActions.SetGenres:
        state.genres = action.genres
        state.genres.insert(Genre(id: -1, name: "Random"), at: 0)
        
    case let action as PeopleActions.SetPeopleCredits:
        if let crews = action.response.crew {
            state = mergeMovies(movies: crews, state: state)
        }
        
        if let casts = action.response.cast {
            state = mergeMovies(movies: casts, state: state)
        }
        
    case let action as MoviesActions.SaveDiscoverFilter:
        state.savedDiscoverFilters.append(action.filter)
        
    case _ as MoviesActions.ClearSavedDiscoverFilters:
        state.savedDiscoverFilters = []
        
    default:
        break
    }
    
    
    return state
}

private func mergeMovies(movies: [Movie], state: MoviesState) -> MoviesState {
    var state = state
    for movie in movies {
        if state.movies[movie.id] == nil {
            state.movies[movie.id] = movie
        }
    }
    return state
}
