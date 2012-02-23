Feature: Guest views a project's page

  Scenario: Guest views a project
    Given there is 1 winning project
    And I am on the homepage
    When I click on that project
    Then I should see the page describing it and all its details

  Scenario: Guest views RSS feed on project page
    Given there is 1 winning project
    And I am on the homepage
    When I click on that project
    Then I should see the project rss feed
