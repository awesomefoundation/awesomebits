Feature: A dean adds custom application intro text

  @javascript
  Scenario: Application intro
    Given I am logged in as a dean
    When I attempt to edit my chapter
    And I update a chapter with custom application intro text
    When I am on the submission page
    And I select the chapter to apply to
    Then I should see custom intro text
