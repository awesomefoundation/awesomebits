import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    scroll: false
  }

  scrollValueChanged() {
    if (this.scrollValue === true)
      this.scroll()
  }

  scroll() {
    this.element.scrollIntoView(true)
    this.scrollValue = false
  }
}
