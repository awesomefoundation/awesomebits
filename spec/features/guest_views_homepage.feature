Feature: A guest views the homepage

  Scenario: Viewing the homepage
    Given there are 5 winning projects
    And those projects' chapters are in 4 countries total
    When I am on the homepage
    Then I should see those 5 chapters
    And I should see those 5 winning projects in their proper order
    And I should see that 5 projects have been funded for $5000
    And I should see that the 5 chapters, not including Any, are spread across 4 countries
