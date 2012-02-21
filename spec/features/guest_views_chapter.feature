Feature: View chapters in the system
  In order to get more informaiton
  A guest should be able to
  View chapter data

  Scenario: Guest can see recent headlines on chapter page
    Given there is a chapter in the system
    When I go to the chapter page
    Then I should see recent headlines

  Scenario: Guest can see list of members on chapter page
    Given there is a chapter in the system
    And there are 5 trustees
    When I go to the chapter page
    Then I should see the trustees
