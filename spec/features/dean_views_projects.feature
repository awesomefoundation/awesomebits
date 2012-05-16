Feature: Dean views all projects

  Scenario: Dean views first page of results by default
    Given I am logged in as a dean
    And there are 31 winning projects in my chapter
    When I am looking at the list of projects for the current chapter
    Then I should see only 30 projects

  Scenario: Dean can view second page
    Given I am logged in as a dean
    And there are 31 winning projects in my chapter
    When I am looking at the list of projects for the current chapter
    And I follow the link to the next page
    Then I should see only 1 project
