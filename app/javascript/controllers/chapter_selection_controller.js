import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker", "select", "chapter", "submit", "error"]

  connect() {
    if (this.hasSelectTarget) this.selectTarget.disabled = false
  }

  submit() {
    if (!this.loading && this.selectTarget.value) this.pickerTarget.requestSubmit()
  }

  start() {
    this.loading = true
    this.selectTarget.disabled = true
    this.errorTarget.hidden = true
    this.submitTargets.forEach(button => { button.disabled = true })
  }

  chapterTargetConnected() {
    if (!this.hasSelectTarget || this.chapterTarget.value === this.selectTarget.value) {
      if (this.loading) {
        const url = new URL(this.pickerTarget.action)
        url.searchParams.set("chapter", this.chapterTarget.value)
        window.history.replaceState(window.history.state, "", url)
      }
      this.loading = false
      if (this.hasSelectTarget) this.selectTarget.disabled = false
      this.submitTargets.forEach(button => { button.disabled = false })
    }
  }

  preventMismatchedChapterSubmission(event) {
    if (this.hasSelectTarget && event.target !== this.pickerTarget && this.hasChapterTarget && this.chapterTarget.value !== this.selectTarget.value) {
      event.preventDefault()
    }
  }

  response(event) {
    const response = event.detail.fetchResponse
    if (!response.succeeded || !response.contentType?.includes("text/vnd.turbo-stream.html")) {
      event.preventDefault()
      this.failed()
    } else {
      // Turbo reads stream bodies asynchronously, after this response event.
      response.responseText.catch(() => this.failed())
    }
  }

  failed(event) {
    event?.preventDefault()
    this.loading = false
    this.selectTarget.value = this.chapterTarget.value
    this.selectTarget.disabled = false
    this.errorTarget.textContent = this.errorTarget.dataset.message
    this.errorTarget.hidden = false
    this.submitTargets.forEach(button => { button.disabled = false })
  }
}
