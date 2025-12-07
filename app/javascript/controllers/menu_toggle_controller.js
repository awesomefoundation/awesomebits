import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { target: String }

  toggle(event) {
    if (event.metaKey || event.ctrlKey || event.shiftKey) {
      return
    }
    
    event.preventDefault()
    const targetElement = document.querySelector(this.targetValue)
    if (targetElement) {
      targetElement.classList.toggle("expanded")
      event.currentTarget.classList.toggle("active")
    }
  }
}
