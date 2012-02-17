Feature: A trustee can see all of the projects up for discussion and shortlist them

  Scenario: A trustee goes to the projects index
    Given I am logged in as a trustee
    And a project was created on each of the last 7 days for my chapter
    And a project was created on each of the last 7 days for a different chapter
    And a project was created on each of the last 7 days for any chapter
    When I am looking at the list of projects
    And I want to see my projects for the past 3 days
    Then I should see my projects for the past 3 days
    And I should not see projects that are not mine
    And I should not see any projects that are 4 or more days old

    When I look at the projects for the "Any" chapter
    Then I should see its projects for the past 3 days

  @javascript
  Scenario: Trustee creates project shortlist
    Given I am logged in as a trustee
    And a project was created on each of the last 7 days for my chapter
    When I am looking at the list of projects
    And I shortlist a project
    Then the project indicates that I have shortlisted it
    When I refresh the page
    Then the correct projects are displayed as shortlisted
    When I de-shortlist that project
    Then none of the projects should be shortlisted

  @javascript
  Scenario: Trustee shortlists a project in "Any"
    Given I am logged in as a trustee
    And I am a trustee for another chapter as well
    And a project was created on each of the last 7 days for any chapter
    When I am looking at the list of projects
    And I look at the projects for the "Any" chapter
    And I shortlist a project
    Then the project indicates that I have shortlisted it
    When I look at the other chapter's finalists
    Then I should see the project I shortlisted
    When I look at my chapter's finalists
    Then I should see the project I shortlisted
