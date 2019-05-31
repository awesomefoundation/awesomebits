Feature: Guest views a project's page

  Scenario: Guest views a project
    Given there is 1 winning project
    And I am on the homepage
    When I click on that project
    Then I should see the page describing it and all its details

  Scenario: Guest views project with no image
    Given there is a project with 0 photos
    And I am on the homepage
    When I view the project
    Then I should see 1 project image on the page
    And I should see the placeholder image

  Scenario: Guest views project with one image
    Given there is a project with 1 photo
    And I am on the homepage
    When I view the project
    Then I should see 1 project image on the page

  Scenario: Guest views a project with multiple images
    Given there is a project with 3 photos
    And I am on the homepage
    When I view the project
    Then I should see 3 project images on the page
