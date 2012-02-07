Feature: As a trustee I can edit my profile

  Scenario: Trustee chagnes password, email, name and twitter handle
    Given I am logged in as a trustee
    When I change my password
    And I change my email
    And I change my name
    And I change my twitter handle
    Then my profile is updated
    And I am notified that my profile has been updated

  Scenario: Trustee adds twitter handle to their profile
    Given I am logged in as a trustee
    When I add a twitter handle
    Then my profile is updated
    And I am notified that my profile has been updated
