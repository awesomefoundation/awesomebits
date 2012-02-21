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

  Scenario: Guest can see previous winners for this chapter
    Given there is a chapter in the system
    And 5 projects have won for this chapter
    And 5 projects have not won for this chapter
    And 5 projects have won, but not for this chapter
    When I go to the chapter page
    Then I should see only those 5 winning projects for this chapter listed
