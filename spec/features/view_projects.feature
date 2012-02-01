Feature: A trustee can see all of the projects up for discussion

  Scenario: A trustee goes to the projects index
    Given I am logged in as a trustee
    And a project was created on each of the last 7 days for my chapter
    And a project was created on each of the last 7 days for a different chapter
    And a project was created on each of the last 7 days for any chapter
    When I go to the projects index
    And I want to see my projects for the past 3 days
    Then I should see my projects for the past 3 days
    And I should not see projects that are not mine
    And I should not see any projects that are 4 or more days old
