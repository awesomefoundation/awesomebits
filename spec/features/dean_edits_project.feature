Feature: Dean edits a project

  @javascript
  Scenario: Dean adds and rearranges some photos to a project
    Given I am logged in as a dean
    And there is 1 winning project in my chapter
    When I edit that winning project
    And I attach 3 photos
    And I go to the public page for that project
    Then I should see the three photos in the carousel

    When I edit that winning project
    And I set the last image to be first
    Then I should see that last image when I load the page
