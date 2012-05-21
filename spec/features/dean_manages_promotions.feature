Feature: Manage Promotions
  As a dean I can modify roles and trustee status
  In order to promote a trustee to a dean

  @javascript
  Scenario: As a dean, I can remove trustee from chapter
    Given I am logged in as a dean
    And there is a trustee for my chapter in the system
    When I remove trustee from my chapter
    Then I should see the deactivated user

  Scenario: As a non-dean, I should not see the trustee demotion links
    Given I am logged in as a trustee
    And there is a trustee for my chapter in the system
    When I try to promote a user
    Then I should not see promotion links
