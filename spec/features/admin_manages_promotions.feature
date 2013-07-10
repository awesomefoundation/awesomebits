Feature: Manage Promotions
  As an admin I can modify roles and admin status
  In order to promote a trustee to a dean or admin

  @javascript
  Scenario: As an admin, I can promote a trustee to an admin
    Given I am logged in as an admin
    And there is a trustee in the system
    When I promote the trustee to admin
    Then I should see the new admin

  @javascript
  Scenario: As an admin, I can promote a trustee of a chapter to be a dean
    Given I am logged in as an admin
    And there is a trustee in the system
    When I promote the trustee to dean
    Then I should see the new dean

  @javascript
  Scenario: As an admin, I can demote dean back to trustee
    Given I am logged in as an admin
    And there is a dean in the system
    When I demote the dean to trustee
    Then I should see the new trustee

  @javascript
  Scenario: As an admin, I can remove trustee from chapter
    Given I am logged in as an admin
    And there is a trustee in the system
    When I remove trustee from a chapter
    Then I should see the deactivated user
