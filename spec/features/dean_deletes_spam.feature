Feature: Deleting projects

  Scenario: Projects are spam, and the dean deletes it
    Given I am logged in as a dean
    And someone has submitted spam to my chapter
    When I go to the projects list
    And I delete the project
    Then I should not see the project anymore
