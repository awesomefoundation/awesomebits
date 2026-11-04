import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.update()
  }

  update() {
    this.element.querySelectorAll("textarea[maxlength], input[maxlength]").forEach(field => {
      const counter = document.getElementById(`${field.id}_chars_left`)
      if (counter) counter.textContent = field.maxLength - field.value.length
    })
  }
}
