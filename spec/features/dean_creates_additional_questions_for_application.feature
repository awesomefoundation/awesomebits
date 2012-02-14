Feature: A dean adds additional questions to the application process

  @javascript
  Scenario: Additional Questions
    Given I am logged in as a dean
    When I attempt to edit my chapter
    And I enter new questions for applicants to answer
    And I submit a project to the "Boston" chapter with the extra questions answered
    Then I should be thanked
    And I should get an email telling me the application went through

    When I view the project in the admin area
    Then I should see the questions and my answers to them

    When I attempt to edit my chapter
    And I enter different questions for applicants to answer
    Then I should see them on the application form
    When I go to the recently submitted project
    Then I should see the questions and my answers to them
