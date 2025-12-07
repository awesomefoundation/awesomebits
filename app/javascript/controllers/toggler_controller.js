import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "toggleable" ]
  static values = { spin: Boolean }

  toggle(event) {
    this.toggleableTarget.classList.toggle('hidden')

    if (this.spinValue) {
      const content = event.currentTarget.querySelector('*')
      if (content) {
        content.classList.add('icon-spin')
        setTimeout(() => {
          content.classList.remove('icon-spin')
        }, 500)
      }
    }

    event.target.blur()
    event.preventDefault()
  }
}
