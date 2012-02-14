Feature: As a trustee I can edit my profile

  Scenario: Trustee changes account information
    Given I am logged in as a trustee
    When I change my profile information
    Then my profile is updated
    And I am on the projects page for my last viewed chapter

  Scenario: Trustee tries to change another users account
    Given I am logged in as a trustee
    And there is another trustee in the system
    When I try to change the other trustees information
    Then I should see an update user permission error

  Scenario: Trustee changes password
    Given I am logged in as a trustee
    When I update my password
    And I log out
    Then I should be able to log in with updated password
