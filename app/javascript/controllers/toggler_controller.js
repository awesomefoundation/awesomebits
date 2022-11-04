import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "toggleable" ]

  toggle(event) {
    $(this.toggleableTarget).toggle('blind')
    $(event.target).blur()
    event.preventDefault()
  }
}
