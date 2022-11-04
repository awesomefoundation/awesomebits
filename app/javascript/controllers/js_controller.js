import { Controller } from "@hotwired/stimulus"

// https://gist.github.com/adrienpoly/862846f5882796fdeb4fc85b260b3c5a
export default class extends Controller {
  static values = { loaded: false }

  connect() {
    this.loadedValue = true
  }
}
