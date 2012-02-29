Feature: A dean can view the voting tally for a chapter

  Scenario: Viewing the tally for a chapter
    Given I am logged in as a dean
    And someone has voted for a project in another chapter
    And votes are cast once per day, consecutively leading up to today
    Given 3 people have voted on a project in my chapter
    And 2 people have voted on another project in my chapter
    And 1 person has voted on another project in my chapter
    And 0 people have voted on another project in my chapter
    When I view the finalists for this month
    Then I should only see the projects with votes in my chapter
    And they should be in descending order of vote count

    When I filter the finalists to only show yesterday and the day before
    Then I should only see that 3 votes that were cast in that time

  Scenario: Switching between chapters
    Given I am logged in as a dean for 2 chapters
    When I view the finalists for the first chapter
    And I select the other chapter from the navigation dropdown
    Then I should see the finalists for the other chapter
