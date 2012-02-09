Feature: A dean picks a winner

  Scenario: A dean picks a winner for a chapter
    Given I am logged in as a dean
    And there are some projects for this month with votes
    When I view the list of projects for this month
    And I pick a winner
    Then the project is visible to the public
    And the submitter of the project gets an email saying they won
