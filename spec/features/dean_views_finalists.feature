Feature: A dean can view the voting tally for a chapter

  Scenario: Viewing the tally for a chapter
    Given I am logged in as a dean
    And someone has voted for a project in another chapter
    And 3 people have voted on a project in my chapter
    And 2 people have voted on another project in my chapter
    And 1 person has voted on another project in my chapter
    And 0 people have voted on another project in my chapter
    When I view the finalists for this month
    Then I should only see the projects with votes in my chapter
    And they should be in descending order of vote count
