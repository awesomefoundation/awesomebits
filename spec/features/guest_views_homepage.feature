Feature: A guest views the homepage

  Scenario: Viewing the homepage
    Given there are 5 chapters
    And there are 5 winning projects
    When I am on the homepage
    Then I should see those 5 chapters
    And I should see those 5 winning projects in their proper order

  Scenario: Viewing the news
    Given there is news on the main news feed
    When I am on the homepage
    Then I should see the news from the feed on the homepage
