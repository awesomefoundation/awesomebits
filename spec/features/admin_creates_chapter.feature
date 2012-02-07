Feature: An admin can create new chapters

  Scenario: An admin creates a chapter
    Given I am logged in as an admin
    When I create a new chapter
    And I go to the chapters index
    Then I should see this new chapter
