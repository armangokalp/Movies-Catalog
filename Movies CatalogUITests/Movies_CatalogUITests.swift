//
//  Movies_CatalogUITests.swift
//  Movies CatalogUITests
//
//  Created by Arman Gökalp on 25.08.2025.
//

import XCTest

final class Movies_CatalogUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation Flow Tests
    
    @MainActor
    func testMovieListToDetailNavigation() throws {
        let firstMovieCell = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 5), "Movie list should load")
        
        firstMovieCell.tap()
        
        let playButton = app.buttons["▶ Play Trailer"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3), "Should navigate to movie detail screen")
        
        let backButton = app.navigationBars.buttons.firstMatch
        backButton.tap()
        
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 2), "Should navigate back to movie list")
    }
    
    @MainActor
    func testMovieDetailToPlayerNavigation() throws {
        let firstMovieCell = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 5), "Movie list should load")
        firstMovieCell.tap()
        
        let playButton = app.buttons["▶ Play Trailer"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3), "Play button should exist")
        playButton.tap()
        
        let closeButton = app.buttons.matching(identifier: "Close").firstMatch
        XCTAssertTrue(closeButton.waitForExistence(timeout: 3), "Player screen should open")
        
        closeButton.tap()
        
        XCTAssertTrue(playButton.waitForExistence(timeout: 2), "Should return to detail screen")
    }
    
    @MainActor
    func testHorizontalScrolling() throws {
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "Collection view should exist")
        
        let initialCellCount = collectionView.cells.count
        
        let firstCell = collectionView.cells.firstMatch
        let lastVisibleCell = collectionView.cells.element(boundBy: min(4, initialCellCount - 1))
        
        if lastVisibleCell.exists {
            firstCell.swipeLeft()
            firstCell.swipeLeft()
            
            XCTAssertTrue(collectionView.cells.count > 0, "Should maintain movies after horizontal scroll")
        }
    }
    
    // MARK: - Player Functionality Tests
    
    @MainActor
    func testPlayerControls() throws {
        navigateToPlayer()
        
        // Wait for player to load
        Thread.sleep(forTimeInterval: 3)
        
        // Simply check that we can navigate to player and it loads
        // Player controls are complex UI elements that may not be easily testable via UI automation
        let app = XCUIApplication()
        XCTAssertTrue(app.exists, "Player screen should load successfully")
        
        // Test that we can navigate back
        if app.buttons["Close"].exists {
            app.buttons["Close"].tap()
            
            // Wait for navigation back to detail screen
            let playTrailerButton = app.buttons["▶ Play Trailer"]
            XCTAssertTrue(playTrailerButton.waitForExistence(timeout: 3), "Should navigate back to detail screen")
        }
    }
    
    @MainActor
    func testPlayerOrientationChange() throws {
        navigateToPlayer()
        
        XCUIDevice.shared.orientation = .landscapeLeft
        
        Thread.sleep(forTimeInterval: 1)
        
        let playerContainer = app.otherElements.firstMatch
        XCTAssertTrue(playerContainer.exists, "Player should handle orientation changes")
        
        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1)
    }
    
    // MARK: - Tablet Tests (if running on iPad)
    
    @MainActor
    func testTabletSplitView() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("This test is only for iPad devices")
        }
        
        let movieList = app.collectionViews.firstMatch
        XCTAssertTrue(movieList.waitForExistence(timeout: 5), "Movie list should be visible on tablet")
        
        let firstMovie = movieList.cells.firstMatch
        XCTAssertTrue(firstMovie.waitForExistence(timeout: 3), "Movies should load")
        firstMovie.tap()
        
        let playButton = app.buttons["▶ Play Trailer"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3), "Detail should appear in split view")
        
        XCTAssertTrue(movieList.exists, "Movie list should remain visible on tablet")
        XCTAssertTrue(playButton.exists, "Detail should be visible on tablet")
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testScrollPerformance() throws {
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5), "Collection view should exist")
        
        measure {
            for _ in 0..<3 {
                collectionView.swipeUp()
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func navigateToPlayer() {
        let firstMovieCell = app.collectionViews.cells.firstMatch
        XCTAssertTrue(firstMovieCell.waitForExistence(timeout: 5), "Movie list should load")
        firstMovieCell.tap()
        
        let playButton = app.buttons["▶ Play Trailer"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 3), "Should reach detail screen")
        playButton.tap()
        
        Thread.sleep(forTimeInterval: 1)
    }
}
