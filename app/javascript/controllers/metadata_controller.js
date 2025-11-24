import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.pageLoadTime = Date.now()
    this.formInteractions = 0
    this.keystrokeCount = 0
    this.pasteCount = 0
  }

  trackInteraction(event) {
    this.formInteractions++
  }

  trackKeystroke(event) {
    const tgt = event.target
    const tag = tgt && tgt.tagName && tgt.tagName.toLowerCase()

    // Only count keystrokes in form fields
    if (!(tag === 'input' || tag === 'textarea' || tgt.isContentEditable)) return

    // Only count printable keys (skip modifiers, arrows, etc.)
    if (event.key && event.key.length !== 1) return

    this.keystrokeCount++
  }

  trackPaste(event) {
    this.pasteCount++
  }

  submit(event) {
    this.injectMetadata()
  }

  getMetadata() {
    return {
      time_on_page_ms: Date.now() - this.pageLoadTime,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      screen_resolution: `${screen.width}x${screen.height}`,
      form_interactions_count: this.formInteractions,
      keystroke_count: this.keystrokeCount,
      paste_count: this.pasteCount
    }
  }

  injectMetadata() {
    const existingField = this.formTarget.querySelector('input[name="client_metadata"]')
    if (existingField) {
      existingField.remove()
    }

    const metadataField = document.createElement('input')
    metadataField.type = 'hidden'
    metadataField.name = 'client_metadata'
    metadataField.value = JSON.stringify(this.getMetadata())

    this.formTarget.appendChild(metadataField)
  }
}
