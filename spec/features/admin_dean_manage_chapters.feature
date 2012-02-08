Feature: Manage Chapters
  An admin can create and modify chapters
  A dean of a chapter can modify the chapter

  Scenario: An admin creates a chapter
    Given I am logged in as an admin
    When I create a new chapter
    And I go to the chapters index
    Then I should see this new chapter

  Scenario: A dean modifies a chapter
    Given I am logged in as a dean
    When I go to the chapters index
    And I click on a chapter I am dean of
    And I click on the edit link
    And I edit the chapter
    Then I should see the updated chapter page

