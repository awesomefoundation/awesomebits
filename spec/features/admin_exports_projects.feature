Feature: Export projects

  In order to download projects
  As an Admin
  I want to export a CSV of projects

  Scenario: admin exports all projects
    Given I am logged in as an admin
    And a project was created on each of the last 7 days for a different chapter
    And a project was created on each of the last 7 days for any chapter
    When I visit a chapters projects page
    And I export all projects
    Then I should receive a CSV file with 14 projects

  Scenario: admin exports a date range of projects  
    Given I am logged in as an admin
    And a project was created on each of the last 7 days for a different chapter
    And a project was created on each of the last 7 days for any chapter
    When I visit a chapters projects page
    And I filter to the last 1 days
    And I export all projects
    Then I should receive a CSV file with 4 projects

  Scenario: dean attempts to export all
    Given I am logged in as a dean
    When I visit a chapters projects page
    Then I should not see the export all link
