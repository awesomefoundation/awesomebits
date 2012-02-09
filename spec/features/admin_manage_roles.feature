Feature: Manage Roles
  As an admin I can modify roles
  In order to promote a trustee to a dean

  Scenario: As an admin, I can promote a trustee of a chapter to be a dean
    Given I am logged in as an admin
    And there is a trustee in the system
    When I go to the users page
    When I promote the trustee to dean
    Then I should see the new dean

  Scenario: As an admin, I can demote dean back to normal trustee
    Given I am logged in as an admin
    And there is a dean in the system
    When I go to the users page
    When I demote the dean to trustee
    Then I should see the new trustee

  Scenario: As a non-admin, I should not see the promotion links
    Given I am logged in as a dean
    And there is a trustee in the system
    When I go to the users page
    Then I should not see promotion links
