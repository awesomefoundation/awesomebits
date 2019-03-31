@javascript
Feature: A dean picks a winner

  Scenario: A dean picks a winner for a chapter
    Given I am logged in as a dean
    And there are some projects for this month with votes
    When I view the list of projects for this month
    And I expand the project menu
    And I pick a winner
    And I log out
    Then the project is visible to the public
    When I log back in
    Then the winning project should look triumphant

  Scenario: The dean has made a terrible, terrible mistake
    Given I am logged in as a dean
    And there are some projects for this month with votes
    When I view the list of projects for this month
    And I expand the project menu
    And I pick a winner
    And I log out
    Then the project is visible to the public
    When I log back in
    And I expand the project menu
    And I revoke the win from that project
    And I log out
    Then the project is no longer visible to the public
    When I log back in
    Then the project looks normal

  Scenario: A dean picks a winner from the "Any" chapter
    Given I am logged in as a dean
    And there are some projects in the "Any" chapter for this month with votes
    When I view the list of projects for this month in the "Any" chapter
    And I expand the project menu
    And I pick a winner for my chapter
    Then I should be on the project page for that project
    When I log out
    Then the project is visible to the public
    When I log back in
    Then the winning project should look triumphant
    And the winning project should belong to my chapter
