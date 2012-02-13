Feature: Admin can view any chapter

  Scenario: Admin uses the chapter selection dropdown to view a chapter
    Given I am logged in as an admin
    And a project was created on each of the last 7 days for one chapter
    And a project was created on each of the last 7 days for a different chapter
    And a project was created on each of the last 7 days for any chapter
    When I am looking at the list of projects for the first chapter
    And I want to see my projects for the past 3 days
    Then I should see my projects for the past 3 days
    And I should not see projects that are not mine
    And I should not see any projects that are 4 or more days old

    When I look at the projects for the "Any" chapter
    Then I should see its projects for the past 3 days

    When I look at the projects for the other chapter
    Then I should see its projects for the past 3 days
