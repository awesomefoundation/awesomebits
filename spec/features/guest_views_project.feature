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

  Scenario: Guest views project with no RSS feed
    Given there is 1 winning project and it has no RSS feed
    And I am on the homepage
    When I click on that project
    Then I should see no feed for the project
