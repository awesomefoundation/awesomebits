import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    expandedClass: 'expanded',
  }

  reveal(event) {
    this.element.classList.add(this.expandedClassValue)
    event.preventDefault()
  }
}
