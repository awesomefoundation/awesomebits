Feature: Admin edits a user

  Scenario: Admin edits a user's email address
    Given I am logged in as an admin
    And there is a trustee in the system
    When I edit that trustee's email address
    Then I should see the change reflected in the list of all users
