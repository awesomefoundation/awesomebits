Feature: A trustee can filter projects by funded status

  Scenario: Trustee can filter projects based on funded status
    Given I am logged in as a trustee
    And a project was created on each of the last 7 days for my chapter
    And there is 1 winning project in my chapter
    When I am looking at the list of projects
    Then I should see only 8 projects
    When I view only funded projects
    Then I should see only 1 project
