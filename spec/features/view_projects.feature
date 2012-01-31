Feature: A trustee can see all of the projects up for discussion

  Scenario: A trustee goes to the projects index
    Given I am logged in as a trustee
    And some projects are from this month
    And some projects are from last month
    And some projects are from this month, but for a different chapter
    And some projects are from this month, but for any chapter
    When I go to the projects index
    Then I should see the projects for this month
    And I should not see the projects for last month
    And I should not see the projects for this month, but for a different chapter
    And I should see the projects for this month, but for any chapter
