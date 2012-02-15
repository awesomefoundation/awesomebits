Feature: A dean picks a winner

  Scenario: A dean picks a winner for a chapter
    Given I am logged in as a dean
    And there are some projects for this month with votes
    When I view the list of projects for this month
    And I pick a winner
    Then the project is visible to the public
    And the submitter of the project gets an email saying they won
    When I log back in
    Then the winning project should look triumphant

  Scenario: The dean has made a terrible, terrible mistake
    Given I am logged in as a dean
    And there are some projects for this month with votes
    When I view the list of projects for this month
    And I pick a winner
    Then the project is visible to the public
    When I log back in
    And I revoke the win from that project
    Then the project is no longer visible to the public
    When I log back in
    Then the project looks normal
