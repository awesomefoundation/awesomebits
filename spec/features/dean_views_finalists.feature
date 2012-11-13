Feature: A dean can view the voting tally for a chapter

  Scenario: Viewing the tally for a chapter
    Given I am logged in as a dean
    And someone has voted for a project in another chapter
    And votes are cast once per day, consecutively leading up to today
    And projects are created the day of the first vote is cast
    Given 3 people have voted on a project in my chapter
    And 2 people have voted on another project in my chapter
    And 1 person has voted on another project in my chapter
    And 0 people have voted on another project in my chapter
    When I view the finalists for this month
    Then I should only see the projects with votes in my chapter
    And they should be in descending order of vote count

    When I filter the finalists to only show the day before yesterday
    Then I should see that 2 votes were cast on projects created in that time

  Scenario: Switching between chapters
    Given I am logged in as a dean for 2 chapters
    When I view the finalists for the first chapter
    And I select the other chapter from the navigation dropdown
    Then I should see the finalists for the other chapter

